import 'package:flutter/material.dart';
import 'package:untitled/utils/config.dart';

//i changed this to stateless??
class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.route, required this.hospital});

  final String route;
  final Map<String, dynamic> hospital;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: 150,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: Colors.white,
          child: Row(
            children: [
              SizedBox(
                width: Config.widthSize * 0.33,
                child:
                    // 3
                    Image.asset(
                  'images/d_hospital.jpg',
                  fit: BoxFit.fill,
                ),
              ),
              Flexible(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          hospital['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Center(
                          child: Text(
                            hospital['location'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        // const Spacer(),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        // ),
                      ],
                    )),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(route, arguments: hospital);
        }, // redirect to doctors details
      ),
    );
  }
}
