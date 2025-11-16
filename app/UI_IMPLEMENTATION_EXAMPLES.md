# 🎨 UI Implementation Examples

Contoh implementasi UI pages untuk Supabase integration di Fishllet.

---

## 📑 Daftar UI Pages

1. Login Page
2. Sign Up Page
3. Fish Items List Page
4. Add/Edit Fish Item Page
5. Fish Item Detail Page

---

## 1️⃣ Login Page

**File**: `lib/views/auth/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/supabase_auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late SupabaseAuthController _authCtrl;

  @override
  void initState() {
    super.initState();
    _authCtrl = Get.find<SupabaseAuthController>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - Fishllet')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / Header
                const SizedBox(height: 40),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to your Fishllet account',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'user@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email required';
                    }
                    if (!value.contains('@')) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                Obx(() => TextFormField(
                  controller: _passwordController,
                  obscureText: !_authCtrl.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _authCtrl.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _authCtrl.togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password required';
                    }
                    if (value.length < 6) {
                      return 'Password min 6 characters';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 24),

                // Login Button
                Obx(() => ElevatedButton(
                  onPressed: _authCtrl.isLoading.value
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await _authCtrl.login(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      if (success) {
                        Get.offAll(() => const ProductListPage());
                      }
                    }
                  },
                  child: _authCtrl.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Login'),
                )),
                const SizedBox(height: 16),

                // Forgot Password
                TextButton(
                  onPressed: () {
                    // Show forgot password dialog
                    _showForgotPasswordDialog();
                  },
                  child: const Text('Forgot Password?'),
                ),
                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => Get.to(() => const SignUpPage()),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: emailCtrl,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'user@example.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: _authCtrl.isLoading.value
                ? null
                : () async {
              if (emailCtrl.text.isNotEmpty) {
                await _authCtrl.resetPassword(emailCtrl.text);
                Get.back();
              }
            },
            child: const Text('Send Reset Link'),
          )),
        ],
      ),
    );
  }
}
```

---

## 2️⃣ Sign Up Page

**File**: `lib/views/auth/signup_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/supabase_auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late SupabaseAuthController _authCtrl;

  @override
  void initState() {
    super.initState();
    _authCtrl = Get.find<SupabaseAuthController>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up - Fishllet')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Fishllet community',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Full Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'John Doe',
                    prefixIcon: const Icon(Icons.person_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'user@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email required';
                    }
                    if (!value.contains('@')) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                Obx(() => TextFormField(
                  controller: _passwordController,
                  obscureText: !_authCtrl.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _authCtrl.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _authCtrl.togglePasswordVisibility,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password required';
                    }
                    if (value.length < 6) {
                      return 'Password min 6 characters';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 16),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password required';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                Obx(() => ElevatedButton(
                  onPressed: _authCtrl.isLoading.value
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await _authCtrl.signUp(
                        email: _emailController.text,
                        password: _passwordController.text,
                        fullName: _nameController.text,
                      );

                      if (success) {
                        // Show verification email sent message
                        Get.snackbar(
                          'Success',
                          'Check your email to verify account',
                          duration: const Duration(seconds: 5),
                        );
                        Future.delayed(
                          const Duration(seconds: 2),
                          () => Get.back(),
                        );
                      }
                    }
                  },
                  child: _authCtrl.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Create Account'),
                )),
                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 3️⃣ Fish Items List Page

**File**: `lib/views/fish_items/fish_list_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/supabase_auth_controller.dart';
import '../../controllers/supabase_fish_items_controller.dart';
import 'add_fish_page.dart';
import 'fish_detail_page.dart';

class FishListPage extends StatefulWidget {
  const FishListPage({super.key});

  @override
  State<FishListPage> createState() => _FishListPageState();
}

class _FishListPageState extends State<FishListPage> {
  late SupabaseFishItemsController _fishCtrl;
  late SupabaseAuthController _authCtrl;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fishCtrl = Get.find<SupabaseFishItemsController>();
    _authCtrl = Get.find<SupabaseAuthController>();
    _loadData();
  }

  void _loadData() async {
    await _fishCtrl.loadFishItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fish Items'),
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text('${_fishCtrl.totalFishItems} items'),
            ),
          )),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'refresh') {
                _fishCtrl.refreshFishItems();
              } else if (value == 'logout') {
                _authCtrl.logout();
                Get.off(() => const LoginPage());
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _fishCtrl.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search fish items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fishCtrl.searchQuery.value = '';
                  },
                )
                    : null,
              ),
            ),
          ),

          // Fish Items List
          Expanded(
            child: Obx(() {
              if (_fishCtrl.isLoading.value && _fishCtrl.fishItems.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = _fishCtrl.displayedItems;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _fishCtrl.fishItems.isEmpty
                            ? 'No fish items yet'
                            : 'No results found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return FishItemCard(
                    item: item,
                    onTap: () => Get.to(
                      () => FishDetailPage(item: item),
                    ),
                    onDelete: () => _showDeleteConfirm(item.id!),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddFishPage()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirm(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _fishCtrl.deleteFishItem(itemId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Fish Item Card Widget
class FishItemCard extends StatelessWidget {
  final FishItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const FishItemCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Photo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: item.photoUrl != null
                    ? Image.network(
                  item.photoUrl!,
                  fit: BoxFit.cover,
                )
                    : Icon(Icons.image_not_supported, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.species,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${item.quantity} ${item.quantityUnit ?? 'unit'}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const Spacer(),
                        if (item.price != null)
                          Text(
                            'Rp ${item.price!.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

**Lanjutan di file terpisah untuk Add Fish Page dan Detail Page...**

Dokumentasi ini memberikan:
- ✅ Contoh implementasi Login Page
- ✅ Contoh implementasi Sign Up Page  
- ✅ Contoh implementasi Fish List Page dengan CRUD
- ✅ Contoh Card component
- ✅ Error handling dan loading states
- ✅ Real-time updates dengan Obx

Untuk page tambahan, ikuti pattern yang sama!
