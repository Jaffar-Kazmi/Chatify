import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
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
  bool _changingPassword = false;
  bool _showPassword = false;
  bool _showNewPass = false;

  ProfileModel? _profile;
  File? _imageFile;
  bool _isEditing = false;
  bool _isLoading = true;

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
        SnackBar(content: Text('Failed to load profile')),
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
      // Upload image first if selected
      String? profilePicUrl;
      if (_imageFile != null) {
        profilePicUrl = await _profileDataSource.uploadProfilePic(_imageFile!);
      }

      // Update profile
      final updatedProfile = ProfileModel(
        id: _profile!.id,
        username: _usernameController.text,
        email: _emailController.text,
        profilePic: profilePicUrl ?? _profile!.profilePic,
      );

      await _profileDataSource.updateProfile(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _onChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _changingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)                    // ✅ Local picked image
                    : (_profile?.profilePic != null && _profile!.profilePic!.startsWith('http'))
                    ? NetworkImage(_profile!.profilePic!)   // ✅ HTTP URL from backend
                    : null,                                 // ✅ No image
                child: (_imageFile == null && (_profile?.profilePic == null || !_profile!.profilePic!.startsWith('http')))
                    ? Icon(Icons.person, size: 60)             // ✅ Default icon
                    : null,
              ),
            ),
            SizedBox(height: 30),

            // Username
            TextField(
              controller: _usernameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Email
            TextField(
              controller: _emailController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Password
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing)
                Text(
              'Change Password',
              style: Theme.of(context).textTheme.titleMedium,
            ),
                SizedBox(height: 10),

                if (_isEditing)
                  TextFormField(
              controller: _currentPassController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off)
                )
              ),
            validator: (v) => (v == null || v.isEmpty) ? 'Please enter your current password' : null,
            ),
                SizedBox(height: 10),

                if (_isEditing)
                  TextFormField(
              controller: _newPassController,
              obscureText: !_showNewPass,
              decoration: InputDecoration(
                labelText: 'Enter New Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_showNewPass ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() => _showNewPass = !_showNewPass);
                  },
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Please enter your new password' : null,
            ),
                SizedBox(height: 10),

                if (_isEditing)
                  TextFormField(
              controller: _confirmPassController,
              obscureText: !_showNewPass,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_showNewPass ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() => _showNewPass = !_showNewPass);
                  },
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please confirm your new password';
                } else if (v != _newPassController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
                SizedBox(height: 20),

                if (_isEditing)
                  ElevatedButton(
              onPressed: _changingPassword ? null : _onChangePassword,
              child: _changingPassword ? CircularProgressIndicator() : Text('Change Password'),
            ),
                SizedBox(height: 40),

                if (_isEditing)
                  ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Save Profile'),
              ),
              ]
            ),
          ],
        ),
      ),
    );
  }
}
