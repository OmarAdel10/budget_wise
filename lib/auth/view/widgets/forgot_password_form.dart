import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budget_wise/auth/view_model/auth_view_model.dart';
import 'package:budget_wise/auth/view_model/auth_event.dart';
import 'package:budget_wise/auth/view_model/auth_state.dart';
import '../../../../shared/constants/spacing.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

class ForgotPasswordForm extends StatefulWidget {
  final String emailHint;
  final String emailRequiredError;
  final String sendResetLinkText;

  const ForgotPasswordForm({
    super.key,
    required this.emailHint,
    required this.emailRequiredError,
    required this.sendResetLinkText,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthEventResetPassword(email: _emailController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            hintText: widget.emailHint,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.emailRequiredError;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                current is AuthStateLoading || previous is AuthStateLoading,
            builder: (context, state) {
              return RepaintBoundary(
                child: CustomButton(
                  text: widget.sendResetLinkText,
                  isLoading: state is AuthStateLoading,
                  onPressed: _onSendResetLink,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
