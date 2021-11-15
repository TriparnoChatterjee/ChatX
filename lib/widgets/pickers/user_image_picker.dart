import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;

  const UserImagePicker(this.imagePickFn);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage = File('');
  void _pickImage() async {
    var picker = ImagePicker();
    final pickedImageFile = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 70, maxWidth: 150);
    setState(() {
      _pickedImage = File(pickedImageFile!.path);
    });
    widget.imagePickFn(File(pickedImageFile!.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage) : null,
          radius: 40,
        ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Click Your Display Picture !')),
      ],
    );
  }
}
