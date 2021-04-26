//flutter packages are imported  here
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//pages are imported here
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:talawa/controllers/auth_controller.dart';
import 'package:talawa/services/queries_.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/gql_client.dart';
import 'package:talawa/utils/globals.dart';
import 'package:talawa/utils/ui_scaling.dart';

class AcceptRequestsPage extends StatefulWidget {
  @override
  _AcceptRequestsPageState createState() => _AcceptRequestsPageState();
}

class _AcceptRequestsPageState extends State<AcceptRequestsPage> {
  final Queries _query = Queries();
  final Preferences _preferences = Preferences();
  static String itemIndex;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  FToast fToast;
  final AuthController _authController = AuthController();
  List membershipRequestsList = [];
  bool loaded = false;
  bool processing = false;

  @override
  void initState() {
    //setting the initial state for the different variables
    super.initState();
    fToast = FToast();
    fToast.init(context);
    viewMemberShipRequests(); //this function is called here to get the request that are sent by the users to get the membership
  }

  Future viewMemberShipRequests() async {
    //Same function giving us the way that a administrator can see the request got from the user to get the membership
    final String orgId = await _preferences.getCurrentOrgId();

    final GraphQLClient _client = graphQLConfiguration.authClient();

    final QueryResult result = await _client.query(QueryOptions(
        documentNode: gql(_query.viewMembershipRequest(
            orgId)))); //calling the graphql query to see the membership request
    if (result.hasException) {
      print(result.exception);
      //showError(result.exception.toString());
    } else if (!result.hasException) {
      print(result.data['organizations'][0]['membershipRequests']);

      setState(() {
        membershipRequestsList =
            result.data['organizations'][0]['membershipRequests'] as List;
        loaded = true;
      });

      if (membershipRequestsList.isEmpty) {
        _exceptionToast('You have no new requests.');
      }
    }
  }

  Future acceptMemberShipRequests() async {
    setState(() {
      processing = true;
    });
    //this function give the functionality of accepting the request of the user by the administrator
    final GraphQLClient _client = graphQLConfiguration.authClient();

    final QueryResult result = await _client.query(QueryOptions(
        documentNode: gql(_query.acceptMembershipRequest(itemIndex))));
    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _authController.getNewToken();
      return acceptMemberShipRequests();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      setState(() {
        processing = false;
      });
      _exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException) {
      setState(() {
        processing = false;
      });
      _successToast('Success');
      viewMemberShipRequests();
    }
  }

  Future rejectMemberShipRequests() async {
    setState(() {
      processing = true;
    });
    //this function give the functionality of rejecting the request of the user by the administrator
    final GraphQLClient _client = graphQLConfiguration.authClient();

    final QueryResult result = await _client.query(QueryOptions(
        documentNode: gql(_query.rejectMembershipRequest(itemIndex))));
    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _authController.getNewToken();
      return rejectMemberShipRequests();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      setState(() {
        processing = false;
      });
      _exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException) {
      setState(() {
        processing = false;
      });
      _successToast('Success');
      viewMemberShipRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    //building the UI page
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Requests',
            style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await viewMemberShipRequests();
        },
        child: (!loaded)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : membershipRequestsList.isEmpty
                ? Center(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: SizeConfig.safeBlockVertical * 31.25,
                        ),
                        const Text(
                          "No request",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical * 6.25,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    //Builds list of awaiting membership requests
                    itemCount: membershipRequestsList.length,
                    itemBuilder: (context, index) {
                      final membershipRequests = membershipRequestsList[index];
                      return Card(
                          child: ListTile(
                              leading: membershipRequests['user']['image'] !=
                                      null
                                  ? CircleAvatar(
                                      radius:
                                          SizeConfig.safeBlockVertical * 3.75,
                                      backgroundImage: NetworkImage(Provider.of<
                                                  GraphQLConfiguration>(context)
                                              .displayImgRoute +
                                          membershipRequests['user']['image']
                                              .toString()))
                                  : CircleAvatar(
                                      radius:
                                          SizeConfig.safeBlockVertical * 3.75,
                                      backgroundImage: const AssetImage(
                                          "assets/images/team.png")),
                              title: Text(
                                  '${membershipRequests['user']['firstName']} ${membershipRequests['user']['lastName']}'),
                              trailing: processing
                                  ? const FittedBox(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Wrap(
                                      spacing: 4,
                                      children: <Widget>[
                                        IconButton(
                                          iconSize: 26.0,
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () {
                                            itemIndex =
                                                membershipRequests['_id']
                                                    .toString();
                                            rejectMemberShipRequests();
                                          },
                                        ),
                                        IconButton(
                                          iconSize: 26.0,
                                          icon: const Icon(Icons.check),
                                          color: Colors.green,
                                          onPressed: () {
                                            itemIndex =
                                                membershipRequests['_id']
                                                    .toString();
                                            acceptMemberShipRequests();
                                          },
                                        ),
                                      ],
                                    )));
                    }),
      ),
    );
  }

  Widget showError(BuildContext context, String msg) {
    //function which will be called if there is some error in the program
    return Center(
      child: Text(
        msg,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  _successToast(String msg) {
    //function to be called when the request is successful
    final Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }

  _exceptionToast(String msg) {
    //this function is used when the exception is called
    final Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }
}
