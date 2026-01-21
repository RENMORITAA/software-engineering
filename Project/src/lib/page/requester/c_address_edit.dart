class AddressEditPage extends StatefulWidget {
  final String initialAddress;
  final String userRole;

  const AddressEditPage({
    super.key,
    this.initialAddress = '',
    this.userRole = 'requester',
  });

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}