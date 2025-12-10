import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../auth/presentation/pages/login_page.dart';
import '../data/datasources/profile_remote_data_sources.dart';
import '../data/models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileDataSource = ProfileRemoteDataSource();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;
  bool _showPasswordFields = false;
  bool _showPassword = false;
  bool _showNewPass = false;
  bool _changingPassword = false;
  File? _imageFile;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      _profile = await _profileDataSource.getProfile();
      _usernameController.text = _profile!.username;
      _emailController.text = _profile!.email;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      String? profilePicUrl;
      if (_imageFile != null) {
        profilePicUrl = await _profileDataSource.uploadProfilePic(_imageFile!);
      }

      final updatedProfile = ProfileModel(
        id: _profile!.id,
        username: _usernameController.text,
        email: _emailController.text,
        profilePic: profilePicUrl ?? _profile!.profilePic,
      );

      await _profileDataSource.updateProfile(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() {
        _isEditing = false;
        _showPasswordFields = false;
        _currentPassController.clear();
        _newPassController.clear();
        _confirmPassController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _onChangePassword() async {
    setState(() => _changingPassword = true);
    try {
      await _profileDataSource.changePassword(
        _currentPassController.text.trim(),
        _newPassController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );

      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
      setState(() => _showPasswordFields = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _changingPassword = false);
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    final storage = FlutterSecureStorage();
    await storage.deleteAll();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: DefaultColors.headerColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryLight,),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            onPressed: () => handleLogout(context),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_profile?.profilePic != null &&
                      _profile!.profilePic!.startsWith('http'))
                      ? NetworkImage(_profile!.profilePic!)
                      : null,
                  child: (_imageFile == null &&
                      (_profile?.profilePic == null ||
                          !_profile!.profilePic!.startsWith('http')))
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              const SizedBox(height: 50),

              // Username
              TextField(
                controller: _usernameController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),

              // Email
              TextField(
                controller: _emailController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 30),

              // CHANGE PASSWORD BUTTON
              if (_isEditing)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showPasswordFields = !_showPasswordFields;
                      _currentPassController.clear();
                      _newPassController.clear();
                      _confirmPassController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceHover,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    _showPasswordFields
                        ? 'Cancel Password Change'
                        : 'Change Password',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

              // PASSWORD FIELDS
              if (_showPasswordFields) ...[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _currentPassController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _newPassController,
                  obscureText: !_showNewPass,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPass ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _showNewPass = !_showNewPass),
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPassController,
                  obscureText: !_showNewPass,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPass ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _showNewPass = !_showNewPass),
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _changingPassword ? null : _onChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceHover,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _changingPassword
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Change Password', style: TextStyle(color: DefaultColors.headerColor),),
                ),
              ],

              const SizedBox(height: 40),

              // SAVE PROFILE BUTTON
              if (_isEditing)
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Profile'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
