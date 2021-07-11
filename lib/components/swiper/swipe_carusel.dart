import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';


abstract class SwipableCard extends StatelessWidget { }


/// A generic swipe carusel usable in [HomeScreen] to display a sequence of
/// [SwipableCard]s. Extend [SwipableCard] and implement your own items.
class SwipeCarusel extends StatelessWidget {

  List<SwipableCard> cards = [];
  var _controller;
  var _pagination;
  SwipeCarusel(this.cards) {
    _pagination = new SwiperPagination();
    _controller = new SwiperControl();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      child: Swiper(
        itemCount: cards.length,
        itemBuilder: (BuildContext context,int index){
          return cards[index];
        },
        pagination: _pagination,
        control: _controller,
        loop: false,
        layout: SwiperLayout.DEFAULT,

      ),
    );
  }
}