import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/cartInfo.dart';

class CartProvide with ChangeNotifier {
  String cartString = '[]';
  List<CartInfoModel> cartList = [];
  double allPrice = 0;
  int allGoodsCount = 0;
  int oneCount = 0;
  bool isOrCheck = true; // 是否全选

// 保存商品数据
  save(goodsId, goodsName, count, price, images) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartString = prefs.getString('cartInfo');// key

    var temp = cartString == null ? [] : json.decode(cartString.toString());
    List<Map> tempList = (temp as List).cast();// 转换list
    // 初始化
    bool isHave = false;
    int ival = 0;
    allPrice = 0;
    allGoodsCount = 0;

    tempList.forEach((item) {
      if (item['goodsId'] == goodsId) {
        tempList[ival]['count'] = item['count']+1;
        // 数据模型
        cartList[ival].count++;
        isHave = true;
      }
      // 如果选中
      if (item['isCheck']) {
        allPrice += (cartList[ival].price * cartList[ival].count);
        allGoodsCount += cartList[ival].count;
      } 
      ival++; // 索引递增
    });

// 如果没有值， 则添加
    if (!isHave) {
      Map<String, dynamic> newGoods = {
        'goodsId': goodsId,
        'goodsName': goodsName,
        'count': count,
        'price': price,
        'images': images,
        'isCheck': true,
      };
      tempList.add(newGoods);
      cartList.add(CartInfoModel.fromJson(newGoods));

      allPrice += (count * price);
      allGoodsCount += count;
    }

    cartString = json.encode(tempList).toString();
    print('字符串>>>>>${cartString}');
    print('数据模型>>>${cartList}');
    prefs.setString('cartInfo', cartString);// 持久化数

    notifyListeners(); // 发射数据
  } 

// 添加商品方法
  // save(goodsId, goodsName, count, price, images) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   cartString = prefs.getString('cartInfo');

  //   var temp = cartString == null ? [] : json.decode(cartString.toString());
  //   List<Map> tempList = (temp as List).cast();

  //   bool isHave = false;
  //   int ival = 0;

  //   tempList.forEach((item) {
  //     if (item['goodsId'] == goodsId) {
  //       tempList[ival]['count'] = item['count']+1;
  //       isHave = true;
  //     }
  //     ival++;
  //   });

  //   if (!isHave) {
  //     Map<String, dynamic> newGoods = {
  //       'goodsId': goodsId,
  //       'goodsName': goodsName,
  //       'count': count,
  //       'price': price,
  //       'images': images
  //     };
  //     tempList.add(newGoods);
  //   }

  //   cartString = json.encode(tempList.toString());
  //   print(cartString);

  //   prefs.setString('cartInfo', cartString);
  //   notifyListeners();

  // }

  // 清空商品数据
  remove() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('cartInfo');
    cartList = []; // 清空模型数据
    print('清空完成........');

    notifyListeners();
  }

// 获得购物车数据
  getCartInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartString = prefs.getString('cartInfo');

  // 清空
    cartList = [];
    if (cartString == null) {
      cartList = [];
    } else {
      List<Map> tempList = (json.decode(cartString.toString())as List).cast(); 
      // 初始化
      allPrice = 0;
      allGoodsCount = 0;
      oneCount = 0;
      isOrCheck = true;
      tempList.forEach((item) {
        if (item['isCheck']) {
          allPrice += (item['count']*item['price']); // 价格
          allGoodsCount += item['count'];// 商品总数
          //oneCount ++;
        } else {
          isOrCheck = false;
        }
        cartList.add(CartInfoModel.fromJson(item));
      });
    }
    notifyListeners();
  }

  // 删除单个购物车商品数据
  deleteOneGoods(String goodsId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartString = prefs.getString('cartInfo');

    // 转换成List Map 类型
    List<Map> tempList = (json.decode(cartString.toString()) as List).cast();
    int tempIndex = 0;
    int delIndex = 0;
    tempList.forEach((item) {
      if (item['goodsId'] == goodsId) {
        delIndex = tempIndex;
      }
      tempIndex++;
    });
    tempList.removeAt(delIndex); // 删除
    cartString = json.encode(tempList).toString();

    prefs.setString('cartInfo', cartString);

    await getCartInfo();
  }

  // 单机单个商品选择按钮
  changeCheckState(CartInfoModel cartItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartString = prefs.getString('cartInfo');
    List<Map> tempList = (json.decode(cartString.toString()) as List).cast();
    int changeIndex = 0;
    int tempIndex = 0;
    tempList.forEach((item) {
      if (item['goodsId'] == cartItem.goodsId) {
        changeIndex = tempIndex;
      }
      changeIndex++;
    });
    tempList[changeIndex] = cartItem.toJson(); // ==> Map
    cartString = json.encode(tempList).toString();

    prefs.setString('cartInfo', cartString);

    await getCartInfo();

  }

  // 点击全选按钮操作
  changeOrCheckBtState(bool isCheck) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartString = prefs.getString('cartInfo');
    List<Map> tempList = (json.decode(cartString.toString()) as List).cast();
    List<Map> newList = [];

    tempList.forEach((item) {
      var newItem = item;
      newItem['isCheck'] = isCheck;
      newList.add(newItem);
    });
    cartString = json.encode(newList).toString();
    prefs.setString('cartInfo', cartString);
    
    await getCartInfo();
  }

  // 商品数量加减
  addOrReducerAction(var cartItem, String todo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartString = prefs.getString('cartInfo');
    List<Map> tempList = (json.decode(cartString.toString()) as List).cast();
    int tempIndex = 0;
    int changeIndex = 0;

    tempList.forEach((item) {
      if (item['goodsId'] == cartItem.goodsId) {
        changeIndex = tempIndex;
      }
      tempIndex++;
    });
    if (todo == 'add') {
      cartItem.count++;
    } else if (cartItem.count > 1){
      cartItem.count--;
    }

    tempList[changeIndex] = cartItem.toJson();
    cartString = json.encode(tempList).toString();

    prefs.setString('cartInfo', cartString);

    await getCartInfo();
  }

}