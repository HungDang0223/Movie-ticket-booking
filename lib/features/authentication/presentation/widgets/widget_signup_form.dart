import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_tickets/core/configs/size_config.dart';
import 'package:movie_tickets/core/extensions/date_time_ext.dart';
import 'package:movie_tickets/core/services/local/vietname_provinces.dart';
import 'package:movie_tickets/core/utils/multi_devices.dart';
import 'package:movie_tickets/core/constants/my_const.dart';
import 'package:movie_tickets/injection.dart';

import '../bloc/signup_bloc/bloc.dart';

class WidgetSignupForm extends StatefulWidget {
  const WidgetSignupForm({super.key});

  @override
  _WidgetSignupFormState createState() => _WidgetSignupFormState();
}

class _WidgetSignupFormState extends State<WidgetSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final now = DateTime.now();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dayOfBirthController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();

  late SignupBloc _signupBloc;

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedWard;

  final VietnamProvinces _vietnamProvinces = VietnamProvinces.ins;
  final genders = ["Nam", "Nữ", "Khác"];

  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime(now.year - 13, now.month, now.day),
        firstDate: DateTime(1900),
        lastDate: DateTime(now.year - 13, now.month, now.day),
        initialEntryMode: DatePickerEntryMode.calendar,);
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        print(_selectedDate);
        _dayOfBirthController.text = _selectedDate!.toFormattedString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _signupBloc = sl<SignupBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      bloc: _signupBloc,
      builder: (context, state) {
        if (state is SignupLoading) {
          return Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
    
        if (state is SignupSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).pushNamed('/login');
            });
          });
        }
    
        if (state is SignupFailed) {
          ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                  'Đăng ký tài khoản thất bại.\n${state.message}',
                  style: MultiDevices.getStyle(fontSize: 13),
                ),
              backgroundColor: AppColor.DEFAULT,
            ),
          );
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            color: AppColor.WHITE,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                      _nameController, "Họ và tên", "Vui lòng nhập họ tên", isRequired: true),
    
                  _buildTextField(_phoneController, "Số điện thoại",
                      "Vui lòng nhập số điện thoại", isRequired: true,
                      keyboardType: TextInputType.phone, ),
    
                  _buildTextField(_emailController, "Email", "Vui lòng nhập email hợp lệ",
                      keyboardType: TextInputType.emailAddress, isRequired: true,
                      validator: (value) =>
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)
                              ? "Email không hợp lệ"
                              : null),
    
                  _buildTextField(_passwordController, "Mật khẩu", "Vui lòng nhập mật khẩu",
                      isRequired: true, obscureText: true),
    
                  _buildTextField(
                    _confirmPasswordController,
                    "Nhập lại mật khẩu", "Mật khẩu không khớp",
                    obscureText: true, isRequired: true,
                    validator: (value) => value != _passwordController.text
                        ? "Mật khẩu không khớp"
                        : null,
                  ),
    
                  // Date of Birth Picker
                  Row(
                    children: [
                      Flexible(
                        flex: 3,
                        child: _buildDropdownTextField(
                          "Ngày sinh",
                          _dayOfBirthController,
                          onTap: () {
                            _pickDate(context);
                          },
                        ),
                      ),
                      SizedBox(width: MultiDevices.getValueByScale(10),),
                      // Gender Picker
                      Flexible(
                        flex: 2,
                        child:
                          _buildDropdownTextField("Giới tính", _genderController, onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => _buildDropdown(
                                    label: "Giới tính",
                                    value: _selectedGender,
                                    items: genders,
                                    onChanged: (value) {
                                      setState(
                                        () => _selectedGender = value);
                                      _genderController.text = _selectedGender!;
                                      print(_selectedGender);
                                      Navigator.pop(context);
                                    },
                                  ));
                        }),
                      ),
                    ],
                  ),
    
                  // Province picker
                  _buildDropdownTextField("Tỉnh/Thành phố", _provinceController, isRequired: true, onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => _buildDropdown(
                              label: "Tỉnh/Thành phố",
                              value: _selectedProvince,
                              items: _vietnamProvinces.getProvinces(),
                              onChanged: (value) {
                                setState(() {
                                _selectedProvince = value;
                                _selectedDistrict = null;
                                _selectedWard = null;
    
                                FocusScope.of(context).unfocus();
                              },);
                              _provinceController.text = _selectedProvince!;
                              print(value);
                              Navigator.pop(context);
                              },
                            ));
                  }),
    
                  // District Picker
                  _buildDropdownTextField("Quận/Huyện/Thị xã", _districtController, isRequired: true, onTap: () {
                    print(_selectedProvince);
                    _selectedProvince == null
                        ? showSnackBar("Vui lòng chọn Tỉnh/Thành phố")
                        : showDialog(
                            context: context,
                            builder: (context) => _buildDropdown(
                                label: "Quận/Huyện/Thị xã *",
                                value: _selectedDistrict,
                                items: _vietnamProvinces.getDistricts(_selectedProvince!),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDistrict = value;
                                    _selectedWard = null;
                                  });
                                  _districtController.text = _selectedDistrict!;
                                  print(_selectedDistrict);
                                  Navigator.pop(context);
                                }));
                  }),
    
                  // Ward Picker
                  _buildDropdownTextField("Xã/Phường/Thị trấn", _wardController,  isRequired: true, onTap: () {
                    _selectedDistrict == null
                        ? showSnackBar("Vui lòng chọn Quận/Huyện/Thị xã")
                        : showDialog(
                            context: context,
                            builder: (context) => _buildDropdown(
                              label: "Xã/Phường/Thị trấn",
                              value: _selectedWard,
                              items: _vietnamProvinces.getWards(_selectedProvince!, _selectedDistrict!),
                              onChanged: (value) {
                                setState(() => _selectedWard = value);
                                _wardController.text = _selectedWard!;
                                print(_selectedWard);
                                Navigator.pop(context);
                              },
                            ));
                  }),
    
                  const SizedBox(height: 20),
    
                  _buildRequiredField(),
    
                  const SizedBox(height: 20,),
    
                  _buildButtonSignup(_signupBloc),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildRequiredField() {
    return Container(
      child: Column(
        children: [
          Text.rich(
            TextSpan(
                children: [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColor.DEFAULT)
                  ),
                  TextSpan(
                    text: "Thông tin bắt buộc",
                    style: MultiDevices.getStyle(
                      fontSize: 14
                    )
                  )
                ]
              ),
              
          ),
        ],
      ),
    );
  }

  _buildButtonSignup(SignupBloc state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: MultiDevices.getValueByScale(10)),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _signupBloc.add(SignupSubmitForm(
              fullName: _nameController.text,
              phoneNumber: _phoneController.text,
              email: _emailController.text,
              password: _passwordController.text,
              dateOfBirth: _selectedDate,
              gender: _selectedGender,
              address: '${_selectedWard!}, ${_selectedDistrict!}, ${_selectedProvince!}',
            ));
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: AppColor.DEFAULT
        ),
        child: Text(
          'Đăng ký'.toUpperCase(),
          style: AppFont.SEMIBOLD_WHITE_18,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    String errorText, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
            label: _customRequiredText(labelText, isRequired: isRequired),
            labelStyle:
                MultiDevices.getStyle(fontSize: 14, color: AppColor.BLACK),
            floatingLabelStyle:
                MultiDevices.getStyle(fontSize: 16, color: AppColor.DEFAULT),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(width: 2, color: AppColor.BLACK)),
            border: const UnderlineInputBorder(
                borderSide: BorderSide(width: 1, color: AppColor.BLACK_30)),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(width: 1, color: AppColor.BLACK_30)),
            disabledBorder: const UnderlineInputBorder()),
        validator: validator ?? (value) => value!.isEmpty ? errorText : null,
      ),
    );
  }

  final FocusNode _focusNode = FocusNode();
  Widget _buildDropdownTextField(String labelText, TextEditingController controller,
  {bool isRequired = false, Function()? onTap}) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        showCursor: false,
        controller: controller,
        decoration: InputDecoration(
            // labelText: controller.text.isNotEmpty ? labelText : null,
            label: controller.text.isNotEmpty ? _customRequiredText(labelText, isRequired: isRequired) : null,
            hintText: controller.text.isEmpty ? labelText : null,
            labelStyle:
                MultiDevices.getStyle(fontSize: 14, color: AppColor.BLACK),
            floatingLabelStyle:
                MultiDevices.getStyle(fontSize: 14, color: AppColor.DEFAULT),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(width: 2, color: AppColor.BLACK)),
            border: const UnderlineInputBorder(
                borderSide: BorderSide(width: 1, color: AppColor.BLACK_30)),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(width: 1, color: AppColor.BLACK2)),
            disabledBorder: const UnderlineInputBorder(),
            suffixIcon: const Icon(Icons.arrow_drop_down)),
        focusNode: _focusNode,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Dialog(
      child: Container(
        width: SizeConfig.screenWidth! * 0.7,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                "Chọn $label",
                style: MultiDevices.getStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 400,
                minHeight: 150
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: SizedBox(
                child: ListView(
                  children: items.map((province) {
                    return Container(
                      color: province == _selectedProvince && _selectedProvince != null ? AppColor.GRAY1_70 : AppColor.WHITE,
                      child: RadioListTile.adaptive(
                        title: Text(province),
                        value: province,
                        groupValue: _selectedProvince,
                        selectedTileColor: AppColor.DEFAULT,
                        activeColor: AppColor.DEFAULT,
                        onChanged: onChanged,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSnackBar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(content), duration: const Duration(milliseconds: 500),));
  }

  Widget _customRequiredText(String labelText, {bool isRequired = false}) {
    return isRequired
      ? Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: labelText
              ),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColor.DEFAULT)
              )
            ]
          )
        )
      : Text(labelText);
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dayOfBirthController.dispose();
    _genderController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _wardController.dispose();
  }
}
