import 'package:billbuddy/Navigation/main_navigation.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // Focus Nodes
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode loginButtonFocusNode = FocusNode();
  final FocusNode passwordVisibilityFocusNode = FocusNode(skipTraversal: true);

  bool isPasswordVisible = false;

  // Login Validation Function
  void signIn() {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username == 'admin' && password == '12345') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainNavigationPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Username or Password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    loginButtonFocusNode.dispose();

    passwordVisibilityFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Login Icon
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),

                const SizedBox(height: 25),

                // Title
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Please sign in to continue',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 35),

                // Username Field
                FocusTraversalOrder(
                  order: const NumericFocusOrder(1),

                  child: TextField(
                    controller: usernameController,
                    focusNode: usernameFocusNode,

                    textInputAction: TextInputAction.next,

                    onSubmitted: (value) {
                      passwordFocusNode.requestFocus();
                    },

                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field
                FocusTraversalOrder(
                  order: const NumericFocusOrder(2),

                  child: TextField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,

                    obscureText: !isPasswordVisible,

                    textInputAction: TextInputAction.done,

                    onSubmitted: (value) {
                      signIn();
                    },

                    decoration: InputDecoration(
                      labelText: 'Password',

                      prefixIcon: const Icon(Icons.lock_outline),

                      suffixIcon: IconButton(
                        focusNode: passwordVisibilityFocusNode,

                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),

                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),

                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Login Button
                FocusTraversalOrder(
                  order: const NumericFocusOrder(3),

                  child: SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: AnimatedBuilder(
                      animation: loginButtonFocusNode,

                      builder: (context, child) {
                        final isFocused = loginButtonFocusNode.hasFocus;

                        return ElevatedButton(
                          focusNode: loginButtonFocusNode,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),

                              side: isFocused
                                  ? const BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    )
                                  : BorderSide.none,
                            ),
                          ),

                          onPressed: signIn,

                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}
