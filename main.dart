import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: "Roboto"),
      home: const LoginPage(),
    );
  }
}

////////////////////////////////////////////////////////////
/// BUBBLE BACKGROUND
////////////////////////////////////////////////////////////

class BubblePainter extends CustomPainter {
  final double t;
  const BubblePainter(this.t);

  static const _data = [
    [0.12, 0.18, 90.0, 0xFF00E5FF],
    [0.82, 0.08, 60.0, 0xFFFF4081],
    [0.68, 0.78, 70.0, 0xFF7C4DFF],
    [0.08, 0.82, 55.0, 0xFF00E676],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in _data) {
      final x = d[0] * size.width;
      final y = d[1] * size.height +
          math.sin((t + d[0]) * 2 * math.pi) * 25;

      final r = d[2] as double;
      final color = Color(d[3].toInt());

      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = color.withOpacity(0.18),
      );
    }
  }

  @override
  bool shouldRepaint(BubblePainter o) => o.t != t;
}

Widget buildBg(AnimationController ctrl, Widget child) {
  return AnimatedBuilder(
    animation: ctrl,
    builder: (ctx, _) => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF090979),
            Color(0xFF020024),
            Color(0xFF000000),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        CustomPaint(
          painter: BubblePainter(ctrl.value),
          size: Size(double.infinity, double.infinity),
          child: const SizedBox.expand(),
        ),
        child,
      ]),
    ),
  );
}

////////////////////////////////////////////////////////////
/// GLASS CARD
////////////////////////////////////////////////////////////

Widget _glassCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 25,
        )
      ],
    ),
    child: child,
  );
}

////////////////////////////////////////////////////////////
/// INPUT FIELD
////////////////////////////////////////////////////////////

Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon,
    Color color, {
      bool obscure = false,
      Widget? suffix,
      String? Function(String?)? validator,
    }) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    validator: validator,
    style: const TextStyle(color: Colors.black),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );
}

////////////////////////////////////////////////////////////
/// BUTTON
////////////////////////////////////////////////////////////

Widget _gradBtn({
  required String label,
  required IconData icon,
  required bool loading,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Colors.cyan,
            Colors.deepPurple
          ],
        ),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

////////////////////////////////////////////////////////////
/// LOGIN PAGE
////////////////////////////////////////////////////////////

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _pass = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  bool remember = false;

  late AnimationController _bg;

  @override
  void initState() {
    super.initState();
    _bg = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6))
      ..repeat();
  }

  Future<void> _login() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 900));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StudentFormPage(username: _user.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: buildBg(
        _bg,
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [

                const Text(
                  "Student Portal",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                _glassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        _field(
                          _user,
                          "Username",
                          Icons.person,
                          Colors.blue,
                          validator: (v) =>
                          v!.isEmpty ? "Enter username" : null,
                        ),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _pass,
                          obscureText: _obscure,
                          style:
                          const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: const TextStyle(
                                color: Colors.black54),
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscure = !_obscure;
                                });
                              },
                            ),
                          ),
                          validator: (v) =>
                          v!.isEmpty ? "Enter password" : null,
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Checkbox(
                              value: remember,
                              onChanged: (v) {
                                setState(() {
                                  remember = v!;
                                });
                              },
                            ),
                            const Text(
                              "Remember Me",
                              style:
                              TextStyle(color: Colors.black),
                            )
                          ],
                        ),

                        const SizedBox(height: 20),

                        _gradBtn(
                          label: "LOGIN",
                          icon: Icons.login,
                          loading: _loading,
                          onTap: _login,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// STUDENT FORM PAGE
////////////////////////////////////////////////////////////

class StudentFormPage extends StatefulWidget {

  final String username;

  const StudentFormPage({super.key, required this.username});

  @override
  State<StudentFormPage> createState() =>
      _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {

  final first = TextEditingController();
  final last = TextEditingController();
  final age = TextEditingController();
  final city = TextEditingController();
  final dob = TextEditingController();
  final dept = TextEditingController();

  String gender = "Male";

  void submit() {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThankYouPage(
          username: widget.username,
          first: first.text,
          last: last.text,
          age: age.text,
          gender: gender,
          city: city.text,
          dob: dob.text,
          dept: dept.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Student Details"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffF6D365),
              Color(0xffFDA085),
            ],
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [

                    TextField(
                      controller: first,
                      decoration:
                      const InputDecoration(labelText: "First Name"),
                    ),

                    TextField(
                      controller: last,
                      decoration:
                      const InputDecoration(labelText: "Last Name"),
                    ),

                    TextField(
                      controller: age,
                      decoration:
                      const InputDecoration(labelText: "Age"),
                    ),

                    Row(
                      children: [

                        const Text("Gender: "),

                        Radio(
                          value: "Male",
                          groupValue: gender,
                          onChanged: (v) {
                            setState(() {
                              gender = v.toString();
                            });
                          },
                        ),
                        const Text("Male"),

                        Radio(
                          value: "Female",
                          groupValue: gender,
                          onChanged: (v) {
                            setState(() {
                              gender = v.toString();
                            });
                          },
                        ),
                        const Text("Female"),
                      ],
                    ),

                    TextField(
                      controller: city,
                      decoration:
                      const InputDecoration(labelText: "City"),
                    ),

                    TextField(
                      controller: dob,
                      decoration:
                      const InputDecoration(labelText: "Date of Birth"),
                    ),

                    TextField(
                      controller: dept,
                      decoration:
                      const InputDecoration(labelText: "Department"),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: submit,
                      child: const Text("Submit"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// THANK YOU PAGE
////////////////////////////////////////////////////////////

class ThankYouPage extends StatelessWidget {

  final String username;
  final String first;
  final String last;
  final String age;
  final String gender;
  final String city;
  final String dob;
  final String dept;

  const ThankYouPage({
    super.key,
    required this.username,
    required this.first,
    required this.last,
    required this.age,
    required this.gender,
    required this.city,
    required this.dob,
    required this.dept,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff11998E),
              Color(0xff38EF7D),
            ],
          ),
        ),

        child: Center(

          child: Card(
            elevation: 15,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),

            child: Padding(
              padding: const EdgeInsets.all(25),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Thank You $username",
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  Text("First Name : $first"),
                  Text("Last Name : $last"),
                  Text("Age : $age"),
                  Text("Gender : $gender"),
                  Text("City : $city"),
                  Text("DOB : $dob"),
                  Text("Department : $dept"),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(
                          context, (route) => route.isFirst);
                    },
                    child: const Text("Back to Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}