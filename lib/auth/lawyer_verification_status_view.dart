import 'package:flutter/material.dart';
import 'package:mwakili/auth/LoginView.dart';
import 'package:mwakili/controller/auth_controller.dart';
import 'package:mwakili/view/User/main_wrapper.dart';
import 'package:mwakili/view/lawer/LawyerMainWrapper.dart';

class LawyerVerificationStatusView extends StatelessWidget {
  final String status;
  final String email;
  final String password;

  LawyerVerificationStatusView({
    Key? key,
    required this.status,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPending = status == "0";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPending ? Icons.hourglass_top_rounded : Icons.gpp_bad_rounded,
                size: 100,
                color: isPending ? Colors.amber : Colors.red,
              ),
              const SizedBox(height: 30),

              Text(
                isPending
                    ? 'طلبك قيد المراجعة والتدقيق'
                    : 'تم رفض طلب الانضمام',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              Text(
                isPending
                    ? 'أهلاً بك في منصة موكلي.\nلقد تم استلام وثائقك المهنية بنجاح، ويقوم فريق الإدارة حالياً بمراجعتها للتحقق من هويتك القانونية تفعيلاً للنظام.\nستستغرق العملية بضع ساعات.'
                    : 'نأسف لإبلاغك بأن إدارة المنصة قامت برفض طلبك بعد مراجعة الوثائق المرفقة، وذلك لعدم وضوح البيانات أو نقص في المستندات الرسمية المرفوعة.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              if (isPending) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    _checkIfVerifiedNow(
                      context,
                      email: email, // ضع هنا البريد المدخل
                      password: password, // ضع هنا كلمة المرور المدخلة
                      isLawyer:
                          true, // حدد ما إذا كان محامياً أم مستخدماً عادياً
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث وفحص الحالة الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginView(isLawyer: true),
                    ),
                  );
                },
                child: Text(
                  isPending
                      ? 'تسجيل الخروج والانتظار'
                      : 'العودة لشاشة تسجيل الدخول',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final AuthController _authController =
      AuthController(); // تأكد من إنشاء كائن من الـ Controller

  void _checkIfVerifiedNow(
    BuildContext context, {
    required String email,
    required String password,
    required bool isLawyer,
  }) async {
    // إظهار رسالة بأن عملية التحقق جارية
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يجري التحقق من تحديثات الحساب وتسيير الدخول...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      print(email + '' + password);
      // استدعاء دالة تسجيل الدخول التي أنشأتها في AuthController
      var result = await _authController.login(
        email: email,
        password: password,
        isLawyer: isLawyer,
      );

      if (!context.mounted) return;
      print("sssssssssssssss");
      print(result['data']['data']['is_verified_panel']);
      print("sssssssssssssss");
      if ((result['success'] == true) &&( result['data']['data']['is_verified_panel'].toString()=="1")) {
        // نجاح تسجيل الدخول وتم حفظ الجلسة بنجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم التحقق وتنشيط الحساب بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        if ((result['success'] == true) && (result['data']['data']['is_verified_panel'].toString()=="1")) {
          // await _manageRememberMeState();

          if (isLawyer) {
            final String isVerified =
                result['data']?['data']?['is_verified_panel']?.toString() ??
                "0";

            if (isVerified == "1") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LawyerMainWrapper(),
                ),
                (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LawyerVerificationStatusView(
                    status: isVerified,
                    email: email,
                    password: password,
                  ),
                ),
                (route) => false,
              );
            }
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainWrapper()),
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'حدث خطأ في تسجيل الدخول'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // هنا يمكنك توجيه المستخدم للشاشة الرئيسية حسب دوره (role)
        // String role = result['role'];
        // Navigator.pushReplacementNamed(context, '/home');
      } else {
        // فشل تسجيل الدخول (ربما لم يتم القبول أو تفعيل الحساب من الإدارة بعد)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'لم يتم تفعيل الحساب بعد، حاول لاحقاً',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      // التعامل مع أي خطأ غير متوقع أثناء الاتصال
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء الاتصال، يرجى المحاولة مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
