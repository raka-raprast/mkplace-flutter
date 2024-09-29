import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final String label;

  const CustomCheckbox({
    Key? key,
    required this.isChecked,
    required this.onChanged,
    this.label = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!isChecked);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 18.0,
            width: 18.0,
            decoration: BoxDecoration(
              color: isChecked ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            child: isChecked
                ? Icon(
                    Icons.check,
                    size: 16.0,
                    color: Colors.white,
                  )
                : null,
          ),
          SizedBox(width: 8.0),
          Text(label),
        ],
      ),
    );
  }
}
