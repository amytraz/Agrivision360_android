import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/routes/app_routes.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String emailOrPhone;
  final bool isMobile;

  const OtpVerificationScreen({
    super.key,
    required this.emailOrPhone,
    required this.isMobile,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit code")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    bool success;
    if (widget.isMobile) {
      success = await authService.verifyMobileOtp(widget.emailOrPhone, _otpController.text);
    } else {
      success = await authService.verifyOtp(widget.emailOrPhone, _otpController.text);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      if (widget.isMobile) {
        // Mobile login is direct
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
      } else {
        // Email signup redirects to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email verified! Please login.")),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid code. Use 123456 for testing.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(
              widget.isMobile ? Icons.sms_outlined : Icons.mark_email_read_outlined,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              "Verification Code",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "We've sent a 6-digit code to\n${widget.emailOrPhone}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 12,
                color: Colors.green,
              ),
              decoration: InputDecoration(
                hintText: "000000",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.3), letterSpacing: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                counterText: "",
              ),
              maxLength: 6,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      "VERIFY",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Didn't receive code? Resend",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
