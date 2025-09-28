import 'package:flutter/material.dart';

class Page3 extends StatelessWidget
{
  const Page3({super.key});


    @override
  Widget build(BuildContext context) {
    
    return Container(
        color: Colors.white,
        child:Column( 
          
          children: [
            //logo 
            SizedBox(height:80),
             Image(image : AssetImage("Assets/ParkFinderLogo.png"),
           width : 100,
           height :100,
           fit:BoxFit.contain,
          
          ),

            //container image 
            SizedBox(height:30),
            Container(
  width: 350,
  height: 450,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    image : DecorationImage(
      image : NetworkImage('https://images.pexels.com/photos/1162251/pexels-photo-1162251.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
      fit: BoxFit.cover,
    
    ),
  ),
),


 //Text
SizedBox(height:20),   
Text("Check weather at parks!" , style: TextStyle(color: Colors.black , fontSize: 25, fontWeight: FontWeight.bold),),

          ],

        ),
         
 
    );
  } 
    
}