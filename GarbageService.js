//GarbageService

//Components
import { Component } from "react";
import XDate from "xdate";
import GarbageDateInfo from "../classes/GarbageDateInfo";

//Helpers
import {strings} from "../Helpers/Localization+Helper";

var GarbageTypeEnum = {
  YellowDumpsterType: 0,
  BlueDumpsterType: 1,
  GreenDumpsterType: 2,
  BrownDumpsterType: 3,
  properties: {
    0: {type: "Yellow dumpster", description: "Metal, plastic products"},
    1: {type: "Blue dumpster", description: "Paper waste"},
    2: {type: "Green dumpster", description: "Glass and articles thereof"},
    3: {type: "Brown dumpster", description: "Food and other biowaste"}
  }, 
  count: 4,
};


export default class GarbageService {

  static sharedInstance = GarbageService.sharedInstance == null ? new GarbageService() : this.sharedInstance
  static infoData =  null;
  static selectedInfoData =  null;

  constructor() {

    this.state = {
      garbageDates: this.garbageDates(),
      garbageInfoData: this.infoData,
      selectedGarbageInfoData: this.selectedInfoData,
    }
  }

  //Methods
  garbageDates = () => {

    if (this.garbageDates.length > 0) {
      return this.garbageDates;
    }

    var dates = new Array();

    var randomDate = require('random-datetime');
    var currentDate = XDate()
    for (month = 1; month < 13; month++) {

      for (index = 0; index < 10; index++) {

        var randomDay = randomDate({
          year: currentDate.getFullYear(),
          month: month
        });

        dates.push(randomDay);
      }
    }

    dates.push(currentDate);

    if (!this.infoData) {
      this.infoData = this.garbageInfoData(dates);
    }

    return dates;
  };

  garbageInfoData = (dates) => {

    let datesInfoArray = [];
    if (dates) {
      for (index in dates) {

        var date = dates[index];
        var dateText = this.dateText(date);

        var garbageInfo = new  GarbageDateInfo();
        garbageInfo.date = date;
        garbageInfo.dateText = dateText;

        garbageInfo.garbageType =  this.getGarbageType(Math.floor(Math.random() * GarbageTypeEnum.count));
        garbageInfo.garbageTypeText = this.getGarbageTypeText(garbageInfo.garbageType);
        garbageInfo.garbageDescription = this.garbageDescription(garbageInfo.garbageType);
        datesInfoArray.push(garbageInfo)
      }
    }
    return datesInfoArray;
  }

  getTime = (date) => {
    
    // Creating variables to hold time.
    var TimeType, hour, minutes, fullTime;
 
    // Getting current hour from Date object.
    hour = date.getHours(); 
 
    // Checking if the Hour is less than equals to 11 then Set the Time format as AM.
    if(hour <= 11)
    {
 
      TimeType = 'am';
 
    }
    else{
      // If the Hour is Not less than equals to 11 then Set the Time format as PM.
      TimeType = 'pm';
 
    }
 
    // IF current hour is grater than 12 then minus 12 from current hour to make it in 12 Hours Format.
    if( hour > 12 )
    {
      hour = hour - 12;
    }
 
    // If hour value is 0 then by default set its value to 12, because 24 means 0 in 24 hours time format. 
    if( hour == 0 )
    {
        hour = 12;
    } 
 
 
    // Getting the current minutes from date object.
    minutes = date.getMinutes();
 
    // Checking if the minutes value is less then 10 then add 0 before minutes.
    if(minutes < 10)
    {
      minutes = '0' + minutes.toString();
    }
 
    // Adding all the variables in fullTime variable.
    fullTime = hour.toString() + ':' + minutes.toString() + ' ' + TimeType.toString();
    return fullTime;
  }

  dateText = (date) => {
    return ('0' + date.getDate()).slice(-2) + '. ' + ('0' + (date.getMonth() + 1)).slice(-2) + '. ' + date.getFullYear() + ' ('  + this.getTime(date) + ')';
  }


  selectedInfoDataForDate = (selectedDate) => {

    var selectedDates = []
    var selectedInfoData = this.state.garbageDates.length > 0 ? this.state.garbageDates : this.garbageDates();

    selectedInfoData = selectedInfoData.filter(function(item) {

      var selectedYear, selectedMonth, selectedDay;

      if (selectedDate.year && selectedDate.month && selectedDate.day) {
        selectedYear = selectedDate.year;
        selectedMonth = selectedDate.month;
        selectedDay = selectedDate.day;
      } else {
        selectedYear = selectedDate.getFullYear();
        selectedMonth = selectedDate.getMonth() + 1;
        selectedDay = selectedDate.getDate();
      }

      if (item.getFullYear() == selectedYear && item.getMonth() + 1 == selectedMonth && item.getDate() == selectedDay) {
        selectedDates.push(item);
      }
   }).map(function({id, name, city}){
       return null;
   });

   this.selectedInfoData = this.garbageInfoData(selectedDates);
    return this.selectedInfoData;
  }

  getGarbageType = (garbageNumber) => {

    var type = GarbageTypeEnum.YellowDumpsterType;
    switch (garbageNumber) {
      case 1: type = GarbageTypeEnum.BlueDumpsterType; break;
      case 2: type = GarbageTypeEnum.GreenDumpsterType; break;
      case 3: type = GarbageTypeEnum.BrownDumpsterType; break;
    }
    return type;
  }

  getGarbageTypeText = (garbageType) => {

    var garbageTypeText = GarbageTypeEnum.properties[0].type;
    garbageTypeText = GarbageTypeEnum.properties[garbageType].type;
    return garbageTypeText;
  }
  
  garbageDescription = (garbageType) => {
    var garbageDescription = GarbageTypeEnum.properties[0].description;
    garbageDescription = GarbageTypeEnum.properties[garbageType].description;
    return garbageDescription;
  }

  render () {
    return null;
  }
}