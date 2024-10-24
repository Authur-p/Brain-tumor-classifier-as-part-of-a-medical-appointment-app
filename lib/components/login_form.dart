import 'package:flutter/material.dart';
import 'api_provider.dart';
import '../utils/config.dart';
import 'button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey_ = GlobalKey<FormState>();
  final _emailController_ = TextEditingController();
  final _passController_ = TextEditingController();
  bool obsecurePass = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey_,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        TextFormField(
          controller: _emailController_,
          keyboardType: TextInputType.emailAddress,
          cursorColor: Config.primaryColor,
          decoration: const InputDecoration(
            hintText: 'Email Address',
            labelText: 'Email',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.email_outlined),
            prefixIconColor: Config.primaryColor,
          ),
        ),
        Config.spaceSmall,
        TextFormField(
          controller: _passController_,
          keyboardType: TextInputType.visiblePassword,
          cursorColor: Config.primaryColor,
          obscureText: obsecurePass,
          decoration: InputDecoration(
            hintText: 'Password',
            labelText: 'Password',
            alignLabelWithHint: true,
            prefixIcon: const Icon(Icons.lock_outline),
            prefixIconColor: Config.primaryColor,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obsecurePass = !obsecurePass;
                });
              },
              icon: obsecurePass
                  ? const Icon(
                      Icons.visibility_off_outlined,
                      color: Colors.black38,
                    )
                  : const Icon(
                      Icons.visibility_outlined,
                      color: Config.primaryColor,
                    ),
            ),
          ),
        ),
        Config.spaceSmall,

        //login button
        Button(
            width: double.infinity,
            title: 'Sign In As User',
            onPressed: () async {
              try {
                //send login request to server
                final token = await getToken(
                    _emailController_.text, _passController_.text);
                // ignore: use_build_context_synchronously
                final user = token != null ? await getUser(token) : null;
                if (user != null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamed('main');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Login Failed'),
                      content:
                          const Text('Please check your email and password.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              } catch (error) {
                print(error);
                return error;
              }
            },
            disable: false),
        Config.spaceSmall,
        const Text('OR'),
        Config.spaceSmall,

        //login button
        Button(
            width: double.infinity,
            title: 'Sign In As Hospital',
            onPressed: () async {
              //send login request to server
              final token = await getHospitalToken(
                  _emailController_.text, _passController_.text);
              // ignore: use_build_context_synchronously
              final user = token != null ? await gethospital(token) : null;
              if (user != null) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamed('hospital_page');
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Login Failed'),
                    content:
                        const Text('Please check your email and password.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            disable: false),
      ]),
    );
  }
}
