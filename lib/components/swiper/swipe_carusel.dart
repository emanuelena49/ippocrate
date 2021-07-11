import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SwipableCard extends StatelessWidget {

  Widget child;
  Color color;
  var onTap;

  SwipableCard({required this.child, required this.color, Function? onTap}) {
    this.onTap = onTap;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: color,
      margin: EdgeInsets.symmetric(
        vertical: 5, horizontal: 8
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 30),
          child: child,
        )
      )
    );
  }
}

/// A generic swipe carusel usable in [HomeScreen] to display a sequence of
/// [SwipableCard]s. Extend [SwipableCard] and implement your own items.
class SwipeCarusel extends StatelessWidget {

  List<Widget> cards = [];
  var _controller;
  var _pagination;
  SwipeCarusel(this.cards) {
    _pagination = new SwiperPagination();
    _controller = new SwiperControl();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: Swiper(
        itemCount: cards.length,
        itemBuilder: (BuildContext context,int index){
          return cards[index];
        },
        pagination: _pagination,
        control: _controller,
        loop: false,
      ),
    );
  }
}