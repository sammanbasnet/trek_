import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.clear();
    _passwordController.clear();
    // Always reset AuthBloc state when login page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(AuthResetRequested());
    });
    _usernameController.addListener(_clearErrorOnInput);
    _passwordController.addListener(_clearErrorOnInput);
  }

  void _clearErrorOnInput() {
    final bloc = context.read<AuthBloc>();
    final state = bloc.state;
    if (state is AuthError) {
      bloc.add(AuthResetRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    // No longer reset AuthBloc state here
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/mountains.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.95 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is Authenticated) {
                    // Clear any error SnackBars before navigating
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  } else if (state is AuthError) {
                    // Clear any previous SnackBars before showing a new one
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      Image.asset('assets/image/trek_logo.png', height: 60),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _clearErrorOnInput(),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (_) => _clearErrorOnInput(),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text("Forgot Password?"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(LoginRequested(_usernameController.text, _passwordController.text));
                        },
                        child: state is AuthLoading ? CircularProgressIndicator() : const Text("Login"),
                      ),
                      const SizedBox(height: 20),
                      const Center(child: Text("Don't have an account?", style: TextStyle(fontFamily:'Opensans Bold'))),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                          // Reset AuthBloc state when navigating to signup
                          context.read<AuthBloc>().add(AuthResetRequested());
                        },
                        child: const Text("Sign up here"),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
