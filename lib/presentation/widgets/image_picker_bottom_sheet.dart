import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final Function(String) onImageSelected;
  final VoidCallback? onCameraSelected;

  const ImagePickerBottomSheet({
    super.key,
    required this.onImageSelected,
    this.onCameraSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Pilih Sumber Gambar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Camera Option
          if (onCameraSelected != null)
            _buildOptionItem(
              context: context,
              icon: Icons.camera_alt,
              title: 'Kamera',
              subtitle: 'Ambil foto menggunakan kamera',
              onTap: () {
                Navigator.pop(context);
                onCameraSelected!();
              },
            ),
          
          // Gallery Option
          _buildOptionItem(
            context: context,
            icon: Icons.photo_library,
            title: 'Galeri',
            subtitle: 'Pilih dari galeri foto',
            onTap: () => _pickImage(ImageSource.gallery, context),
          ),
          
          const SizedBox(height: 8),
          
          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          size: 32,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _pickImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      Navigator.pop(context);
      onImageSelected(pickedFile.path);
    }
  }
}