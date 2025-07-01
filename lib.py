import os

def create_directory_structure(base_path):
    # Define the directory structure as a nested dictionary
    structure = {
        'lib': {
            'main.dart': '',
            'app.dart': '',
            'core': {
                'constants': {
                    'api_constants.dart': '',
                    'app_constants.dart': '',
                    'storage_keys.dart': '',
                },
                'config': {
                    'app_config.dart': '',
                    'environment.dart': '',
                },
                'utils': {
                    'device_utils.dart': '',
                    'validators.dart': '',
                    'formatters.dart': '',
                    'extensions.dart': '',
                },
                'errors': {
                    'app_exception.dart': '',
                    'error_handler.dart': '',
                },
                'network': {
                    'api_client.dart': '',
                    'api_interceptor.dart': '',
                    'network_info.dart': '',
                },
            },
            'data': {
                'models': {
                    'auth': {
                        'login_request.dart': '',
                        'login_response.dart': '',
                        'register_request.dart': '',
                        'user_model.dart': '',
                    },
                    'wallet': {
                        'transaction_model.dart': '',
                        'deposit_request.dart': '',
                        'withdrawal_request.dart': '',
                        'wallet_history.dart': '',
                    },
                    'portfolio': {
                        'portfolio_model.dart': '',
                        'investment_model.dart': '',
                    },
                    'loans': {
                        'loan_model.dart': '',
                        'loan_application.dart': '',
                        'emi_calculation.dart': '',
                    },
                    'tasks': {
                        'task_model.dart': '',
                        'task_submission.dart': '',
                        'task_category.dart': '',
                    },
                    'referrals': {
                        'referral_model.dart': '',
                        'referral_earnings.dart': '',
                    },
                    'kyc': {
                        'kyc_model.dart': '',
                        'kyc_document.dart': '',
                    },
                    'notifications': {
                        'notification_model.dart': '',
                    },
                    'common': {
                        'api_response.dart': '',
                        'pagination.dart': '',
                        'device_info.dart': '',
                    },
                },
                'repositories': {
                    'auth_repository.dart': '',
                    'wallet_repository.dart': '',
                    'portfolio_repository.dart': '',
                    'loans_repository.dart': '',
                    'tasks_repository.dart': '',
                    'referrals_repository.dart': '',
                    'kyc_repository.dart': '',
                    'notifications_repository.dart': '',
                    'user_repository.dart': '',
                },
                'services': {
                    'api_service.dart': '',
                    'auth_service.dart': '',
                    'storage_service.dart': '',
                    'device_service.dart': '',
                    'notification_service.dart': '',
                    'biometric_service.dart': '',
                },
            },
            'presentation': {
                'providers': {
                    'auth_provider.dart': '',
                    'dashboard_provider.dart': '',
                    'wallet_provider.dart': '',
                    'portfolio_provider.dart': '',
                    'loans_provider.dart': '',
                    'tasks_provider.dart': '',
                    'referrals_provider.dart': '',
                    'kyc_provider.dart': '',
                    'notifications_provider.dart': '',
                    'app_state_provider.dart': '',
                },
                'screens': {
                    'auth': {
                        'login_screen.dart': '',
                        'register_screen.dart': '',
                        'forgot_password_screen.dart': '',
                        'verify_otp_screen.dart': '',
                    },
                    'dashboard': {
                        'dashboard_screen.dart': '',
                        'widgets': {
                            'balance_card.dart': '',
                            'quick_actions.dart': '',
                            'recent_transactions.dart': '',
                            'portfolio_overview.dart': '',
                        },
                    },
                    'wallet': {
                        'wallet_screen.dart': '',
                        'deposit_screen.dart': '',
                        'withdrawal_screen.dart': '',
                        'transaction_history_screen.dart': '',
                        'widgets': {
                            'deposit_form.dart': '',
                            'withdrawal_form.dart': '',
                            'transaction_item.dart': '',
                        },
                    },
                    'portfolio': {
                        'portfolio_screen.dart': '',
                        'investment_details_screen.dart': '',
                        'widgets': {
                            'portfolio_chart.dart': '',
                            'investment_card.dart': '',
                            'performance_metrics.dart': '',
                        },
                    },
                    'loans': {
                        'loans_screen.dart': '',
                        'loan_application_screen.dart': '',
                        'loan_details_screen.dart': '',
                        'emi_calculator_screen.dart': '',
                        'widgets': {
                            'loan_card.dart': '',
                            'emi_calculator.dart': '',
                            'repayment_schedule.dart': '',
                        },
                    },
                    'tasks': {
                        'tasks_screen.dart': '',
                        'task_details_screen.dart': '',
                        'task_submission_screen.dart': '',
                        'widgets': {
                            'task_card.dart': '',
                            'task_filter.dart': '',
                            'submission_form.dart': '',
                        },
                    },
                    'referrals': {
                        'referrals_screen.dart': '',
                        'referral_earnings_screen.dart': '',
                        'widgets': {
                            'referral_stats.dart': '',
                            'referral_link.dart': '',
                            'earnings_chart.dart': '',
                        },
                    },
                    'kyc': {
                        'kyc_screen.dart': '',
                        'document_upload_screen.dart': '',
                        'widgets': {
                            'kyc_status.dart': '',
                            'document_upload.dart': '',
                            'verification_steps.dart': '',
                        },
                    },
                    'profile': {
                        'profile_screen.dart': '',
                        'settings_screen.dart': '',
                        'security_screen.dart': '',
                        'preferences_screen.dart': '',
                        'widgets': {
                            'profile_header.dart': '',
                            'settings_section.dart': '',
                            'security_options.dart': '',
                        },
                    },
                    'notifications': {
                        'notifications_screen.dart': '',
                        'widgets': {
                            'notification_item.dart': '',
                        },
                    },
                    'support': {
                        'support_screen.dart': '',
                        'create_ticket_screen.dart': '',
                        'ticket_details_screen.dart': '',
                        'widgets': {
                            'ticket_card.dart': '',
                            'faq_item.dart': '',
                        },
                    },
                },
                'widgets': {
                    'app_bar.dart': '',
                    'bottom_nav_bar.dart': '',
                    'loading_overlay.dart': '',
                    'error_dialog.dart': '',
                    'success_dialog.dart': '',
                    'confirmation_dialog.dart': '',
                    'biometric_dialog.dart': '',
                },
            },
            'router': {
                'app_router.dart': '',
                'route_paths.dart': '',
                'route_guards.dart': '',
            },
        },
    }

    def create_files_and_dirs(current_path, items):
        for name, content in items.items():
            new_path = os.path.join(current_path, name)
            if isinstance(content, dict):
                # Create directory
                os.makedirs(new_path, exist_ok=True)
                # Recursively create subdirectories and files
                create_files_and_dirs(new_path, content)
            else:
                # Create file
                with open(new_path, 'w') as f:
                    f.write(content)

    # Create base directory if it doesn't exist
    os.makedirs(base_path, exist_ok=True)
    # Create the directory structure
    create_files_and_dirs(base_path, structure)
    print(f"Directory structure created successfully at {base_path}")

if __name__ == "__main__":
    # Set the base path where the structure will be created
    base_path = "project_structure"
    create_directory_structure(base_path)