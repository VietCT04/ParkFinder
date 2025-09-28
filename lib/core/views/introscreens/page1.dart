import 'package:flutter/material.dart';

class Page1 extends StatelessWidget
{
  const Page1({super.key});


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
      image : NetworkImage('https://images.pexels.com/photos/18787361/pexels-photo-18787361/free-photo-of-view-of-palm-trees-and-the-marina-bay-sands-hotel-in-singapore.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
      fit: BoxFit.cover,
    
    ),
  ),
),


 //Text
SizedBox(height:20),   
Text("Find Parks!" , style: TextStyle(color: Colors.black , fontSize: 25, fontWeight: FontWeight.bold),),

          ],

        ),
         
 
    );
  } 
    
}