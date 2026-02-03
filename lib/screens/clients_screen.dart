import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/clients_store.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<ClientDoc> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    items = await ClientsStore.load();
    setState(() => loading = false);
  }

  Future<void> addClient() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddClientScreen()));
    await load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text("Meus Clientes"),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.gold,
        foregroundColor: Colors.black,
        onPressed: addClient,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Text("Nenhum cliente cadastrado.",
                      style: TextStyle(color: Colors.white.withOpacity(.75))))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final c = items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: AppTheme.border.withOpacity(.35)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, color: AppTheme.gold),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name.isEmpty ? "Sem nome" : c.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(c.phone,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(.7))),
                                if (c.email.isNotEmpty)
                                  Text(c.email,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(.6))),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await ClientsStore.delete(c.id);
                              await load();
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addrCtrl = TextEditingController();
  final cpfCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addrCtrl.dispose();
    cpfCtrl.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final doc = ClientDoc(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      address: addrCtrl.text.trim(),
      cpfCnpj: cpfCtrl.text.trim(),
    );
    await ClientsStore.upsert(doc);
    if (!mounted) return;
    Navigator.pop(context);
  }

  InputDecoration dec(String label) => InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.black.withOpacity(.18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.gold.withOpacity(.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.gold),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text("Adicionar Cliente"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.card,
                foregroundColor: AppTheme.gold,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text("Importar contatos entra no próximo pack.")),
                );
              },
              child: const Text("Importar de meus Contatos",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(controller: nameCtrl, decoration: dec("Nome do Cliente")),
          const SizedBox(height: 10),
          TextField(
              controller: phoneCtrl,
              decoration: dec("Telefone/Celular do Cliente com ...")),
          const SizedBox(height: 10),
          TextField(
              controller: emailCtrl,
              decoration: dec("Email do Cliente (Opcional)")),
          const SizedBox(height: 10),
          TextField(
              controller: addrCtrl,
              decoration: dec("Endereço do Cliente (Opcional)")),
          const SizedBox(height: 10),
          TextField(
              controller: cpfCtrl, decoration: dec("Cpf ou Cnpj (Opcional)")),
          const SizedBox(height: 14),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.card,
                foregroundColor: AppTheme.gold,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: save,
              child: const Text("Adicionar Cliente",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
