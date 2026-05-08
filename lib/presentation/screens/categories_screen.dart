import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/category_provider.dart';
import '../../data/models/category_model.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'GESTIÓN DE CATEGORÍAS',
          style: TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w900, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: _buildBackgroundShape(const Color(0xFFFFCDD2).withOpacity(0.1), 300),
          ),
          SafeArea(
            child: Consumer<CategoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF0000)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildGlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: category.color.withOpacity(0.1),
                              child: Icon(category.icon, color: category.color, size: 20),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436)),
                                  ),
                                  Text(
                                    category.isIncome ? 'Ingreso' : 'Egreso',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                              onPressed: () => _confirmDelete(context, provider, category),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryModal(context),
        backgroundColor: const Color(0xFFFF0000),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBackgroundShape(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
          ),
          child: child,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryProvider provider, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar categoría?'),
        content: const Text('Esta acción no se puede deshacer. Las transacciones existentes mantendrán su ID.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              provider.deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCategoryModal(),
    );
  }
}

class AddCategoryModal extends StatefulWidget {
  const AddCategoryModal({super.key});

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final _nameController = TextEditingController();
  bool _isIncome = false;
  IconData _selectedIcon = Icons.star_rounded;
  Color _selectedColor = const Color(0xFFFF0000);

  final List<IconData> _availableIcons = [
    // Técnicos
    Icons.electrical_services_rounded,
    Icons.handyman_rounded,
    Icons.build_rounded,
    Icons.bolt_rounded,
    Icons.settings_suggest_rounded,
    // Negocios
    Icons.description_rounded,
    Icons.request_quote_rounded,
    Icons.account_balance_rounded,
    Icons.badge_rounded,
    // Logística
    Icons.local_shipping_rounded,
    Icons.ev_station_rounded,
    Icons.location_on_rounded,
    // Hogar / Varios
    Icons.cleaning_services_rounded,
    Icons.security_rounded,
    Icons.inventory_2_rounded,
    Icons.shopping_cart_rounded,
    Icons.restaurant_rounded,
    Icons.movie_filter_rounded,
    Icons.star_rounded,
    Icons.more_horiz_rounded,
  ];

  final List<Color> _availableColors = [
    const Color(0xFFFF0000), // Rojo Intenso
    const Color(0xFF2E7D32), // Verde
    const Color(0xFF1976D2), // Azul
    const Color(0xFFFFA000), // Ámbar
    const Color(0xFF7B1FA2), // Púrpura
    const Color(0xFFC2185B), // Rosa
    const Color(0xFF0097A7), // Cian
    const Color(0xFF5D4037), // Marrón
    const Color(0xFF455A64), // Gris Azulado
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 25,
        left: 25,
        right: 25,
        bottom: MediaQuery.of(context).viewInsets.bottom + 25,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('NUEVA CATEGORÍA', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2D3436))),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la Categoría',
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton('Egreso', !_isIncome, () => setState(() => _isIncome = false)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTypeButton('Ingreso', _isIncome, () => setState(() => _isIncome = true)),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text('Elegir Icono', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            const SizedBox(height: 15),
            
            // Grid de Iconos
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final icon = _availableIcons[index];
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF0000).withOpacity(0.1) : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: const Color(0xFFFF0000), width: 2) : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? const Color(0xFFFF0000) : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 25),
            const Text('Elegir Color', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            const SizedBox(height: 15),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 45,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.black, width: 3) : Border.all(color: Colors.white, width: 2),
                        boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)] : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text('GUARDAR CATEGORÍA', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF0000) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey[600]),
        ),
      ),
    );
  }

  void _saveCategory() {
    if (_nameController.text.isEmpty) return;

    final newCategory = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      icon: _selectedIcon,
      color: _selectedColor,
      isIncome: _isIncome,
    );

    context.read<CategoryProvider>().addCategory(newCategory);
    Navigator.pop(context);
  }
}
