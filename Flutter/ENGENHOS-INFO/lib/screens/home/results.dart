import 'dart:convert';
import 'dart:async';
import 'package:engenhos_info/shared/loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../../models/myuser.dart';
import '../../services/auth.dart';
import 'package:http/http.dart' as http;

class Results extends StatefulWidget {
  Results({Key? key, this.results}) : super(key: key);
  Map? results;
  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {

  final AuthService _auth = AuthService();
  late dynamic resultMap;
  String pathImg='';
  bool loading = false;

  Future<void> getStorageUrl(String fileName) async {

    Reference storage = FirebaseStorage.instance.ref().child('imagesFromUsers/$fileName');
    Future.delayed(const Duration(seconds: 5));
    pathImg = await storage.getDownloadURL();
    setState(() {
      pathImg = pathImg;
    });
    print(pathImg);
  }

  @override
  void initState() {
    super.initState();
    // res = Result(uid: '${widget.results!['userID']}');
    if(widget.results?['imgName'] != null) {
      getStorageUrl(widget.results?['imgName']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ? const Loading() : Scaffold(
      appBar: AppBar(
        //color: Color(0xffFBD732)
        backgroundColor: Colors.black,
        leading: MaterialButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Image.asset(
            'assets/Logo-BG-70.png',
            scale: 1,
          ),
        ),
        leadingWidth: 100,
        actions: <Widget> [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaterialButton(
                textColor: Colors.grey[400],
                onPressed: () {
                  //redirect to form
                  Navigator.pushReplacementNamed(context, '/formdata');
                },
                child: const Text(
                  "Form",
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                shape: const CircleBorder(
                    side: BorderSide(
                      color: Colors.transparent,
                    )
                ),
              ),
              MaterialButton(
                textColor: const Color(0xffFBD732),
                onPressed: () {
                  if (resultMap != null) {
                    //redirect to results
                    Navigator.of(context).pushReplacement(                                                         //new
                        MaterialPageRoute(                                                                       //new
                            settings: const RouteSettings(name: '/results'),                                              //new
                            builder: (context) => Results(results: resultMap)
                        )                                                                                            //new
                    ); }
                  else {
                    resultMap = {'imgPath':'assets/Logo-PS2.png', 'result':'Nothing to analyze!'};
                    Navigator.of(context).pushReplacement(                                                         //new
                        MaterialPageRoute(                                                                       //new
                            settings: const RouteSettings(name: '/results'),                                              //new
                            builder: (context) => Results(results: resultMap)
                        )                                                                                            //new
                    );
                  }
                },
                child: const Text(
                  "Results",
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
              MaterialButton(
                textColor: Colors.grey[400],
                onPressed: () {
                  //redirect to profile
                  Navigator.pushReplacementNamed(context, '/profile');
                },
                child: const Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
      // body: ResultsSlide(results: widget.results),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text('Here is your result!',
              style: TextStyle(
                color: Color(0xffFBD732),
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoMono',
              ),),
              Container(
                height: 350,
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(pathImg,),
                  ),
                ),
              ),
              Text('Result: ${widget.results!['result']}',
                style: TextStyle(color: Colors.grey[400], fontSize: 22.0, fontStyle: FontStyle.italic, fontFamily: 'Raleway'),),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        elevation: 10.0,
        shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              onPressed: _takepicture,
              color: Colors.black,
              focusColor: Colors.grey[400],
              padding: const EdgeInsets.all(17.0),
              child: Row(
                children: <Widget> [
                  const Icon(
                    Icons.camera,
                    color: Color(0xffFBD732),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.grey[400],
                      wordSpacing: 2,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              onPressed: () async {
                _showLogoutDialog();
              },
              color: Colors.black,
              focusColor: Colors.grey[400],
              padding: const EdgeInsets.all(17.0),
              child: Row(
                children: <Widget> [
                  const Icon(
                    Icons.logout,
                    color: Color(0xffFBD732),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.grey[400],
                      wordSpacing: 2,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),

      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('LogOut'),
          content: SingleChildScrollView(
            child: Column(
              children: const <Widget>[
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('YES'),
              onPressed: () async {
                await _auth.signOut().then((_) => Navigator.pushReplacementNamed(context, '/wrapper'));
                // Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _takepicture() async {
    final PickedFile? img = await ImagePicker.platform.pickImage(source: ImageSource.camera);
    if(img != null) {
      setState(() {
        loading = true;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
    MyUser user = Provider.of<MyUser>(context, listen: false);
    LocationData loc = await Location().getLocation();
    var url = Uri.http('10.0.2.2:5000', '/image');

    http.MultipartRequest request = http.MultipartRequest('POST', url);

    request.fields['userID'] = user.uid;
    request.fields['latitude'] = '${loc.latitude}';
    request.fields['longitude'] = '${loc.longitude}';
    request.fields['imgPath'] = '${img?.path}';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        img!.path,
        contentType: MediaType('file', 'jpg'),
      ),
    );

    request.send().then((response) async {
      if (response.statusCode == 200) {
        setState(() {
          loading = true;
        });
        resultMap = request.fields;
        http.Response.fromStream(response).then((value) {
          if(value.statusCode == 200) {
            print("Uploaded!");
            resultMap = jsonDecode(value.body);
            print(jsonDecode(value.body));
          }
          // return resultMap;
        }).then((_)  {
          Navigator.of(context).pushReplacement(                                                         //new
              MaterialPageRoute(                                                                       //new
                  settings: const RouteSettings(name: '/results'),                                              //new
                  builder: (context) => Results(results: resultMap)
              )                                                                                            //new
          );
        });
        // print(resultMap);
      } else {
        setState(() {
          loading = true;
        });
      }
    });
  }

}
