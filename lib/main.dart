import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasesocialauth/social-settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/twitter_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FirebaseSocialAuth());
}

class FirebaseSocialAuth extends StatelessWidget {
  const FirebaseSocialAuth({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Firebase Social Auth',
      home: HomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool emailpass = true;

  TextEditingController _email = TextEditingController();
  TextEditingController _pwd = TextEditingController();
  TextEditingController _phone = TextEditingController();

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token.toString());

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<UserCredential> signInWithTwitter() async {
    // Create a TwitterLogin instance
    //I was created a file called social-settings.dart from
    //which below used variables are coming for data
    //which is not available in github.
    final twitterLogin = new TwitterLogin(
        apiKey: twitter_api_key,
        apiSecretKey: twitter_api_secret,
        redirectURI: firebase_redirect_url
    );

    // Trigger the sign-in flow
    final authResult = twitterLogin.login();

    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: twitter_token,
      secret: twitter_token_secret,

      //accessToken: authResult.authToken!,
      //secret: authResult.authTokenSecret!,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                emailpass
                    ? loginWithEmailPassword(context, _email, _pwd)
                    : loginWithPhoneNumber(context, _phone),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //EmailPassword
                    IconButton(
                      onPressed: () {
                        setState(() {
                          emailpass = true;
                        });
                      },
                      icon: const FaIcon(FontAwesomeIcons.envelope),
                    ),
                    //PhoneNumber
                    IconButton(
                      onPressed: () {
                        setState(() {
                          emailpass = false;
                        });
                      },
                      icon: const FaIcon(FontAwesomeIcons.phone),
                    ),
                    //GoogleAuth
                    IconButton(
                      onPressed: () {
                        try{
                          signInWithGoogle().whenComplete(() {
                            toast('Sign in with Google successful');
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage()));
                          });
                        }on FirebaseAuthException catch (e){
                          print(e.message.toString());
                        }

                      },
                      icon: const FaIcon(FontAwesomeIcons.google),
                    ),
                    //FacebookAuth
                    IconButton(
                      onPressed: () {
                        signInWithFacebook().whenComplete((){
                          toast('Sign in with Facebook successful');
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage()));
                        });
                      },
                      icon: const FaIcon(FontAwesomeIcons.facebook),
                    ),
                    //TwitterAuth
                    IconButton(
                      onPressed: () {
                        signInWithTwitter().whenComplete((){
                          toast('Twitter auth successful');
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage()));
                        });
                      },
                      icon: const FaIcon(FontAwesomeIcons.twitter),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const FaIcon(FontAwesomeIcons.github),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const FaIcon(FontAwesomeIcons.microsoft),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome :)'),
      ),
    );
  }
}

void toast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}

showAlertDialog(BuildContext context, email, password) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget signInButton = TextButton(
    child: Text("Sign Up"),
    onPressed: () async {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DashboardPage()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showAlertDialog(context, 'The password provided is too weak.');
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          _showAlertDialog(
              context, 'The account already exists for that email.');
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Message"),
    content: Text("No user found for the user. Would you like to sign up?"),
    actions: [
      cancelButton,
      signInButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

_showAlertDialog(BuildContext context, message) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Alert"),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Widget loginWithEmailPassword(BuildContext context, TextEditingController _email, TextEditingController _pwd){
  return Container(
    height: 250,
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 30,
            color: Colors.lightGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'with Email & Password',
          style: TextStyle(
            fontSize: 15,
            color: Colors.teal,
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'you@domain.com',
            icon: FaIcon(FontAwesomeIcons.envelope),
            labelStyle: TextStyle(
              color: Colors.blueGrey,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          controller: _email,
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Password',
            hintText: '******',
            icon: FaIcon(FontAwesomeIcons.key),
            labelStyle: TextStyle(
              color: Colors.blueGrey,
            ),
          ),
          keyboardType: TextInputType.text,
          controller: _pwd,
          obscureText: true,
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              UserCredential userCredential =
              await FirebaseAuth
                  .instance
                  .signInWithEmailAndPassword(
                  email: _email.text,
                  password: _pwd.text);

              toast('Login to app successful');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const DashboardPage()));
            } on FirebaseAuthException catch (e) {
              if (e.code == 'user-not-found') {
                showAlertDialog(
                    context, _email.text, _pwd.text);
                print('No user found for that email.');
              } else if (e.code == 'wrong-password') {
                print(
                    'Wrong password provided for that user.');
              }
            }
          },
          child: const Text('Sign In'),
        )
      ],
    ),
  );
}

Widget loginWithPhoneNumber(BuildContext context, TextEditingController _phone){
  return Container(
    height: 200,
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 30,
            color: Colors.lightGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'with Phone Number',
          style: TextStyle(
            fontSize: 15,
            color: Colors.teal,
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'country code + number',
            icon: FaIcon(FontAwesomeIcons.phone),
            labelStyle: TextStyle(
              color: Colors.blueGrey,
            ),
          ),
          keyboardType: TextInputType.number,
          controller: _phone,
        ),
        ElevatedButton(
          onPressed: () async {
            print(_phone.text);
            await FirebaseAuth.instance.verifyPhoneNumber(
              phoneNumber: _phone.text,
              verificationCompleted:
                  (PhoneAuthCredential credential) async {
                toast(
                    'Phone verification completed successfully');
                try {
                  final auth = await FirebaseAuth
                      .instance
                      .signInWithCredential(credential);
                  if (auth.user != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const DashboardPage()));
                  }
                } on FirebaseAuthException catch (e) {
                  toast(e.message.toString());
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const DashboardPage()));
              },
              verificationFailed:
                  (FirebaseAuthException e) {
                print('ERROR' + e.message.toString());
                toast(
                    'Your given phone number is invalid, please, try again');
              },
              codeSent: (String verificationId,
                  int? resendToken) {
                toast(
                    'Verification code sent to given number');
              },
              codeAutoRetrievalTimeout:
                  (String verificationId) {
                toast(
                    'OTP verification failed. Please, try again');
              },
            );
          },
          child: const Text('Sign In'),
        )
      ],
    ),
  );
}
