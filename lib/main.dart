import 'package:flutter/material.dart';
import "./check.dart";
import 'dart:math';

var random = new Random();
const success = "http://127.0.0.1:3000/response.js";
const failure = "http://127.0.0.1:3000/response.js";
var username = "sdfggdsg_1210";
var password = "ABN_SP1210";
var programID = "5666";
var clientCode = "ABN01";
var authKey = "wRAKcWb8WjGSU8Z2";
var authIV = "9oaIkb7SCYunVDYg";
var txnId = random.nextInt(1000000000);
var tnxAmt = 10;
var URLsuccess = success.trim();
var URLfailure = failure.trim();
var payerFirstName = "Mukesh";
var payerLastName = "Kumar";
var payerContact = "8796541230";
var payerAddress = "xyz abc";
var payerEmail = "test@gmail.com";
var channelId = "m";
void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      "/": (_) => PaymentProcess(
          rechargevalues: RechargeValues(
            clientName: clientCode,
              Email: payerEmail,
              contactNo: "3242342234",
              channelId: channelId,
              pass: password,
              
              amt: tnxAmt.toString(),
              firstName: payerFirstName,
              Add:payerAddress,
              failureURL: URLfailure,
              ru:URLsuccess,
              usern: username,
              txnId: txnId.toString(),
              programId: programID,

              lstName: payerLastName))
    },
  ));
}
