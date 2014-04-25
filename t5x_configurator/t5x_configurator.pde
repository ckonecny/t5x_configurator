/**
* T5x Configurator
*
*
* by Christian Konecny, 2014
*
*/


import controlP5.*;
import processing.serial.*;
import java.util.Map;

ControlP5       cp5;
Serial          gSerialPort;  


final static byte FLIGHTMODES    = 6;
final static byte CHANNELS       = 8;
final static byte AXES           = 3; // AIL, ELE, RUD


/////////// Profile Properties /////////////////

// Channel Slider & DropDown
Slider[]       gChannelSl                          = new Slider[CHANNELS];
DropdownList[] gChannelDdl                         = new DropdownList[CHANNELS];
Map<Character,Integer> gChannelLayoutCharToIndexMap= new HashMap<Character,Integer>();
char[]         gChannelLayoutChar                  = new char[10];


// Expo & Dualrate
Numberbox[][] gExpNb      = new Numberbox[AXES][FLIGHTMODES]; 
Numberbox[][] gDRNb       = new Numberbox[AXES][FLIGHTMODES];

// VFM
Numberbox[] gVFMSwitchLevelsNb = new Numberbox[FLIGHTMODES];

// Aircraft Telemetry Stuff
Numberbox[]   gV_A1Nb     = new Numberbox[3];
Numberbox[]   gV_A2Nb     = new Numberbox[4];

// FlightTimer
Numberbox      gFlightTimerNb;
int            gFlightTimer;


/////////// Transmitter Properties /////////////////

// TBD: calibration values with MIN, MID, MAX, Reverse for A0-A7 
//      switch reverse 
//      VFM Steps

// Telemetry Interval
Numberbox     gTelemetryIntervalNb;

// Transmitter Voltage & RSSI 
Numberbox[]   gV_TXNb   = new Numberbox[3];
Numberbox[]   gRSSINb   = new Numberbox[2];

// Analog Inputs & Switches
Slider[]       gAnalogSl        = new Slider[8];
Numberbox[][]  gAnalogCalibrationNb = new  Numberbox[8][3]; // 8 analog inputs; MIN,MID,MAX
CheckBox       gAnalogReverseCb; 
CheckBox       gSwitchReverseCb; 
RadioButton    gSW1StateRb;       // BiState
RadioButton    gSW2StateRb;       // TriState
RadioButton    gSW3StateRb;       // TriState
RadioButton    gFlightModeSwitchRb;
RadioButton    gPrimaryProfileSwitchRb;

// Throttle Timer Threshold
Numberbox     gThrottleTimerThresholdNb;
int           gThrTimerThreshold;

Textlabel     gCurrentFlightModeTl;
Textlabel     gFreeRAMTl;
Textlabel     gLoopTimeTl;
Textlabel     gFlightTimerSecTl;
Textlabel     gActiveProfileIdTl;




//////////// General things ////////////////////
// Serial & Connect
DropdownList   gSerialDdl;
//Button         gConnectBut;


Button         gLoadBut;
Button         gApplyBut;
Button         gSaveBut;



// Drop Down for selecting Profile 
//DropdownList   gProfileDdl;


int            gSerialPortIndex=-1;
byte[] Buffer = new byte[255];
int            byteCount=0;


// Helper function for Expo/DR Table Row Description
void createExpDrRowCaption(String aName, int aRowId)
{
     cp5.addTextlabel("ExpDrRowLabel_"+aName)
        .setText(aName)
        .setPosition(430+6*35-5,40+aRowId*15+2)
        .setColorValue(0xffffffff)
        ; 
}


void setup() {
  size(700,600);
  
  cp5 = new ControlP5(this);
     

   cp5.addTextlabel("gInputs")
      .setText("Input:")
      .setPosition(15, 320)
      .setColorValue(0xffffffff)
         .setFont(createFont("",12))
      ; 

   cp5.addTextlabel("gOutputs")
      .setText("PPM Output:")
      .setPosition(15, 15)
      .setColorValue(0xffffffff)
         .setFont(createFont("",12))
      ; 
        
//////// Expo / Dual-Rate Table /////////////////////////////////////

  // Table Header
  for (int i=0;i<FLIGHTMODES;i++)
  {
     String name="FM"+(i+1);
     cp5.addTextlabel(name)
        .setText(name)
        .setPosition(430+i*35,28)
        .setColorValue(0xffffffff)
        ;
  }   

  // Table Row Description
  createExpDrRowCaption("Expo AIL",0);
  createExpDrRowCaption("Expo ELE",1);
  createExpDrRowCaption("Expo RUD",2);
  createExpDrRowCaption("DR AIL",4);
  createExpDrRowCaption("DR ELE",5);
  createExpDrRowCaption("DR RUD",6);

  for(int axis=0;axis<AXES;axis++) // AIL, ELE, RUD
  {
    for(int fm=0;fm<FLIGHTMODES;fm++)     // flightmode 0-5
    {
      String name="gEXP_"+axis+"_"+fm;
      gExpNb[axis][fm]=cp5.addNumberbox(name)
                          .setPosition(430+fm*35,40+axis*15)
                          .setSize(30,12)
                          .setRange(-100, 100)
                          .setMultiplier(-0.1)
                          .setDecimalPrecision(0)
                          ;
      gExpNb[axis][fm].getCaptionLabel().setVisible(false);
      
      name="gDR_"+axis+"_"+fm;
      gDRNb[axis][fm]=cp5.addNumberbox(name)
                          .setPosition(430+fm*35,40+15*(AXES+1)+axis*15)
                          .setSize(30,12)
                          .setRange(0, 140)
                          .setMultiplier(-0.1)
                          .setDecimalPrecision(0)
                          ;
      gDRNb[axis][fm].getCaptionLabel().setVisible(false);
    }  
  }
//////////////////////////////////////////////////////////////////////////

   for(int fm=0;fm<FLIGHTMODES;fm++)     // flightmode 0-5
    {
      String name="gVFM_"+fm;
      gVFMSwitchLevelsNb[fm]=cp5.addNumberbox(name)
                                .setPosition(430+fm*35,40+120)
                                .setSize(30,12)
                                .setRange(-256, 256)
                                .setMultiplier(-0.1)
                                .setDecimalPrecision(0)
                                ;
      gVFMSwitchLevelsNb[fm].getCaptionLabel().setVisible(false);
    }
    
  createExpDrRowCaption("VFM STEPS",8);


     cp5.addTextlabel("V_A1")
        .setText("A1")
        .setPosition(45, 190)
        .setColorValue(0xffffffff)
        ; 

     cp5.addTextlabel("V_A2")
        .setText("A2")
        .setPosition(85, 190)
        .setColorValue(0xffffffff)
        ; 

     cp5.addTextlabel("V_TX")
        .setText("TX")
        .setPosition(155, 190)
        .setColorValue(0xffffffff)
        ; 


  gV_A1Nb[0] = cp5.addNumberbox("gA1cells")
                .setPosition(40,200)
                .setSize(30,12)
                .setRange(0,10)
                .setMultiplier(-0.1)
                .setDecimalPrecision(0)
                ;

  gV_A1Nb[1] = cp5.addNumberbox("gA1_V_ORANGE")
                .setPosition(40,220)
                .setSize(30,12)
                .setRange(0,20)
                .setMultiplier(-0.01)
                .setDecimalPrecision(1)
                ;

  gV_A1Nb[2] = cp5.addNumberbox("gA1_V_RED")
                .setPosition(40,240)
                .setSize(30,12)
                .setRange(0,20)
                .setMultiplier(-0.01)
                .setDecimalPrecision(1)
               ;

  gV_A2Nb[0] = cp5.addNumberbox("gA2cells")
                 .setPosition(80,200)
                .setSize(30,12)
                .setRange(0,10)
                .setMultiplier(-0.1)
                .setDecimalPrecision(0)
                ;

  gV_A2Nb[1] = cp5.addNumberbox("gA2_V_ORANGE")
                .setPosition(80,220)
                .setSize(30,12)
                .setRange(0,20)
                .setMultiplier(-0.01)
                .setDecimalPrecision(1)
                ;

  gV_A2Nb[2] = cp5.addNumberbox("gA2_V_RED")
                  .setPosition(80,240)
                  .setSize(30,12)
                  .setRange(0,20)
                  .setMultiplier(-0.01)
                  .setDecimalPrecision(1)
                  ;

  gV_A2Nb[3] = cp5.addNumberbox("gA2VoltageDividerRatio")
                  .setPosition(80,260)
                  .setSize(30,12)
                  .setRange(1,10)
                  .setMultiplier(-0.1)
                  .setDecimalPrecision(0)
                  .setLabel("Divider Ratio")
                  ;
                  
                  
  gV_TXNb[0] = cp5.addNumberbox("gTXcells")
                .setPosition(150,200)
                .setSize(30,12)
                .setRange(0,10)
                .setScrollSensitivity(0.05)
                .setMultiplier(-0.1)
                .setDecimalPrecision(0)
                .setLabel("cells")
                ;

  gV_TXNb[1] = cp5.addNumberbox("gTX_V_ORANGE")
                .setPosition(150,220)
                .setSize(30,12)
                .setRange(0,20)
                .setMultiplier(-0.01)
                .setDecimalPrecision(1)
                .setLabel("V warning")
                ;

  gV_TXNb[2] = cp5.addNumberbox("gTX_V_RED")
                .setPosition(150,240)
                .setSize(30,12)
                .setRange(0,20)
                .setMultiplier(-0.01)
                .setDecimalPrecision(1)
                .setLabel("V alarm")
                ;
                

  for (int i=0;i<3;i++)
  {
    gV_A1Nb[i].getCaptionLabel().setVisible(false);
    gV_A2Nb[i].getCaptionLabel().setVisible(false);    
    gV_TXNb[i].captionLabel().style().marginTop=-14;
    gV_TXNb[i].captionLabel().style().marginLeft=35;
  }
  
    gV_A2Nb[3].captionLabel().style().marginTop=-14;
    gV_A2Nb[3].captionLabel().style().marginLeft=-60;

  gRSSINb[0] = cp5.addNumberbox("RSSI_ORANGE")
                .setLabel("% RSSI warning")
                .setPosition(240,220)
                .setSize(30,12)
                .setRange(0,100)
                .setMultiplier(-0.1)
                .setDecimalPrecision(0)
              ;

  gRSSINb[1] = cp5.addNumberbox("RSSI_RED")
                  .setLabel("% RSSI alarm")
                  .setPosition(240,240)
                  .setSize(30,12)
                  .setRange(0,100)
                  .setMultiplier(-0.1)
                  .setDecimalPrecision(0)
                  ;

   gRSSINb[0].captionLabel().style().marginTop=-14;
   gRSSINb[0].captionLabel().style().marginLeft=35;
   gRSSINb[1].captionLabel().style().marginTop=-14;
   gRSSINb[1].captionLabel().style().marginLeft=35;


  gTelemetryIntervalNb = cp5.addNumberbox("TelemetryInterval")
                            .setLabel("Telem. Check Interval (sec)")
                            .setPosition(240,200)
                            .setSize(30,12)
                            .setRange(0,255)
                            .setMultiplier(-0.1)
                            .setDecimalPrecision(0)
                            ;

   gTelemetryIntervalNb.captionLabel().style().marginTop=-14;
   gTelemetryIntervalNb.captionLabel().style().marginLeft=35;


  gFlightTimerNb = cp5.addNumberbox("gFlightTimer")
                     .setLabel("Timer (sec)")
                     .setPosition(150,260)
                     .setSize(30,12)
                     .setRange(1, 18000)
                     .setMultiplier(-1);
                     ;

  gFlightTimerNb.captionLabel().style().marginTop=-14;
  gFlightTimerNb.captionLabel().style().marginLeft=35;



  gThrottleTimerThresholdNb = cp5.addNumberbox("gThrTimerThreshold")
     .setLabel("% throttle to trigger Timer")
     .setPosition(240,260)
     .setSize(30,12)
     .setRange(0, 100)
     .setValue(0)
     .setMultiplier(-1)
     ;

  gThrottleTimerThresholdNb.captionLabel().style().marginTop=-14;
  gThrottleTimerThresholdNb.captionLabel().style().marginLeft=35;
     
  


//////// Channel Bars & Drop Down fields for channel alignment /////////////////////////////////////
  for(int c=0;c<CHANNELS;c++)
  {
    String name="ChannelBar_"+c;
    
    gChannelSl[c]=cp5.addSlider(name)
                     .setLabel("CH"+(c+1))
                     .setPosition(20+50*c,40)
                     .setSize(20,100)
                     .setRange(750,2250)
                     .setLock(true)
                     .setDecimalPrecision(0)
                     ;
 
     gChannelSl[c].captionLabel().style().marginLeft=6;
//     gChannelSl[c].valueLabel().setVisible(false);

 
    name="Channel_"+c;
    gChannelDdl[c] = cp5.addDropdownList(name)
                        .setPosition(20+50*c,170)
                        .setSize(30,200)
                        ;
       
     gChannelDdl[c].addItem("AIL",0); 
     gChannelDdl[c].addItem("ELE",1);
     gChannelDdl[c].addItem("THR",2);
     gChannelDdl[c].addItem("RUD",3);
     gChannelDdl[c].addItem("SW1",4);
     gChannelDdl[c].addItem("SW2",5);
     gChannelDdl[c].addItem("SW3",6);
     gChannelDdl[c].addItem("POT",7);
     gChannelDdl[c].addItem("VFM",8);
     gChannelDdl[c].addItem(" - ",9); 
  
     gChannelDdl[c].setValue(9);
     gChannelDdl[c].bringToFront();   
   } 
  
   // we want to map in both directions, i.e. from index to character
   gChannelLayoutChar[0]='A';
   gChannelLayoutChar[1]='E';
   gChannelLayoutChar[2]='T';
   gChannelLayoutChar[3]='R';
   gChannelLayoutChar[4]='1';
   gChannelLayoutChar[5]='2';
   gChannelLayoutChar[6]='3';
   gChannelLayoutChar[7]='P';
   gChannelLayoutChar[8]='M';
   gChannelLayoutChar[9]='-';

   gChannelLayoutCharToIndexMap.put('A',0);
   gChannelLayoutCharToIndexMap.put('E',1);
   gChannelLayoutCharToIndexMap.put('T',2);
   gChannelLayoutCharToIndexMap.put('R',3);
   gChannelLayoutCharToIndexMap.put('1',4);
   gChannelLayoutCharToIndexMap.put('2',5);
   gChannelLayoutCharToIndexMap.put('3',6);
   gChannelLayoutCharToIndexMap.put('P',7);
   gChannelLayoutCharToIndexMap.put('M',8);
   gChannelLayoutCharToIndexMap.put('-',9);
   
//////////////////////////////////////////////////////////////////////////
  for(int i=0;i<8;i++)
  {
    gAnalogSl[i]=cp5.addSlider("Analog_"+i)
                     .setLabel("A"+i)
                     .setPosition(20+50*i,340)
                     .setSize(20,100)
                     .setRange(0,1024)
               //      .setLabelVisible(false)
                     .setLock(true)
                     .setDecimalPrecision(0)
                     ;
    gAnalogSl[i].captionLabel().style().marginLeft=6;
//    gAnalogSl[i].valueLabel().setVisible(false);
    
    
    for(int j=0;j<3;j++)       // MIN,MID,MAX
    {
      gAnalogCalibrationNb[i][j]=cp5.addNumberbox("gAnalogCalibration_"+i+"_"+j)
                                    .setPosition(15+50*i,520-j*15)
                                    .setSize(30,12)
                                    .setRange(0, 1024)
                                    .setMultiplier(-0.1)
                                    .setDecimalPrecision(0)
                                    ;
      gAnalogCalibrationNb[i][j].getCaptionLabel().setVisible(false);
    }
  }
 
      cp5.addTextlabel("gAnalogCalib_MAXLb")
        .setText("MAX")
        .setPosition(400,492)
        .setColorValue(0xffffffff)
        ;

      cp5.addTextlabel("gAnalogCalib_MIDLb")
        .setText("MID")
        .setPosition(400,507)
        .setColorValue(0xffffffff)
        ;

      cp5.addTextlabel("gAnalogCalib_MINLb")
        .setText("MIN")
        .setPosition(400,522)
        .setColorValue(0xffffffff)
        ;

 


 
  
     gAnalogReverseCb = cp5.addCheckBox("gAnalogReverse")
                          .setPosition(25, 460)
                          .setColorForeground(color(120))
                          .setColorActive(color(255))
                          .setColorLabel(color(255))
                          .setSize(10, 10)
                          .setItemsPerRow(8)
                          .setSpacingColumn(40)
                          .setSpacingRow(20)
                          .addItem("A0", 0)
                          .addItem("A1", 1)
                          .addItem("A2", 2)
                          .addItem("A3", 3)
                          .addItem("A4", 4)
                          .addItem("A5", 5)
                          .addItem("A6", 6)
                          .addItem("A7", 7)
                          .hideLabels()
                          ;  

     gSwitchReverseCb = cp5.addCheckBox("gSwitchReverse")
                          .setPosition(435, 460)
                          .setColorForeground(color(120))
                          .setColorActive(color(255))
                          .setColorLabel(color(255))
                          .setSize(10, 10)
                          .setItemsPerRow(3)
                          .setSpacingColumn(30)
                          .setSpacingRow(20)
                          .addItem("SW1Reverse", 0)
                          .addItem("SW2Reverse", 1)
                          .addItem("SW3Reverse", 2)
                          .hideLabels()
                          ;  

   
      cp5.addTextlabel("PrimaryProfileLabel")
          .setText("Primary Profile Switch")
          .setPosition(540,420)
          .setColorValue(0xffffffff)
          ;

      cp5.addTextlabel("FlightModeSwitchLabel")
          .setText("Flight Mode Switch")
          .setPosition(540,440)
          .setColorValue(0xffffffff)
          ;
   
       cp5.addTextlabel("ReverseLabel")
          .setText("Reverse")
          .setPosition(540,460)
          .setColorValue(0xffffffff)
          ;
  

     
     for (int i=0;i<3;i++)
     {
       cp5.addTextlabel("SW"+(i+1))
          .setText("SW"+(i+1))
          .setPosition(430+40*i,345)
          .setColorValue(0xffffffff)
          ;
     } 

     cp5.addTextlabel("SwitchUpLabel")
        .setText("UP")
        .setPosition(540,360)
        .setColorValue(0xffffffff)
        ;

     cp5.addTextlabel("SwitchCenterLabel")
        .setText("CENTER")
        .setPosition(540,380)
        .setColorValue(0xffffffff)
        ;

     cp5.addTextlabel("SwitchDownLabel")
        .setText("DOWN")
        .setPosition(540,400)
        .setColorValue(0xffffffff)
        ;



    gSW1StateRb = cp5.addRadioButton("gSW1State")
                     .setPosition(435, 360)
                     .setColorForeground(color(120))
                     .setColorActive(color(255))
                     .setColorLabel(color(255))
                     .setSize(10, 10)
                     .setItemsPerRow(1)
                     .setSpacingColumn(0)
                     .setSpacingRow(10)
                     .addItem("SW1UP", 0)
                     .addItem("SW1CENTER", 1)
                     .addItem("SW1DOWN", 2)
                     .hideLabels()
                      ;

    gSW2StateRb = cp5.addRadioButton("gSW2State")
                     .setPosition(475, 360)
                     .setColorForeground(color(120))
                     .setColorActive(color(255))
                     .setColorLabel(color(255))
                     .setSize(10, 10)
                     .setItemsPerRow(1)
                     .setSpacingColumn(0)
                     .setSpacingRow(10)
                     .addItem("SW2UP", 0)
                     .addItem("SW2CENTER", 1)
                     .addItem("SW2DOWN", 2)
                     .hideLabels()
                   ;

    gSW3StateRb = cp5.addRadioButton("gSW3State")
                     .setPosition(515, 360)
                     .setColorForeground(color(120))
                     .setColorActive(color(255))
                     .setColorLabel(color(255))
                     .setSize(10, 10)
                     .setItemsPerRow(1)
                     .setSpacingColumn(0)
                     .setSpacingRow(10)
                     .addItem("SW3UP", 0)
                     .addItem("SW3CENTER", 1)
                     .addItem("SW3DOWN", 2)
                     .hideLabels()
                     ;


    gPrimaryProfileSwitchRb = cp5.addRadioButton("gPrimaryProfileSelector")
                                 .setPosition(475, 420)
                                 .setColorForeground(color(120))
                                 .setColorActive(color(255))
                                 .setColorLabel(color(255))
                                 .setSize(10, 10)
                                 .setItemsPerRow(2)
                                 .setSpacingColumn(30)
                                 .setSpacingRow(0)
                                 .addItem("PrimaryProfileSW3", 0)
                                 .addItem("PrimaryProfileSW2", 1)
                                 .hideLabels()
                                 ;
    gFlightModeSwitchRb = cp5.addRadioButton("gFlightModeSwitch")
                                 .setPosition(475, 440)
                                 .setColorForeground(color(120))
                                 .setColorActive(color(255))
                                 .setColorLabel(color(255))
                                 .setSize(10, 10)
                                 .setItemsPerRow(2)
                                 .setSpacingColumn(30)
                                 .setSpacingRow(0)
                                 .addItem("FlightModeSW3", 0)
                                 .addItem("FlightModeSW2", 1)
                                 .hideLabels()
                                 ;




/*
     gProfileDdl = cp5.addDropdownList("gProfileId")
                      .setPosition(435,515)
                      .setSize(160,80)
                      ;
       
     for (int i=0;i<9;i++)
       gProfileDdl.addItem("Profile " +(i+1),i); 
  
     gProfileDdl.setValue(0);
*/

   try
   {
     gSerialPort = new Serial(this, Serial.list()[0], 9600);
     gSerialPortIndex=0;
   }
   catch (Exception e)
   {
     gSerialPortIndex=-1;
     println("Serial port does not work for some reason...");
   }

  gLoadBut = cp5.addButton("gLoad")
                .setLabel("Load")
                .setPosition(435,505)
                .setSize(40,12)
                ;

  gApplyBut = cp5.addButton("gApply")
                .setLabel("Apply")
                .setPosition(485,505)
                .setSize(40,12)
                ;

  gSaveBut = cp5.addButton("gSave")
                .setLabel("Save")
                .setPosition(535,505)
                .setSize(40,12)
                ;


                    
  gCurrentFlightModeTl = cp5.addTextlabel("gCurrentFlightMode")
                            .setText("Active Flightmode: N/A")
                            .setPosition(480,15)
                            .setColorValue(0xffffffff)
                            ; 
/*                    
  gConnectBut = cp5.addButton("gConnect")
                  .setLabel("Connect")
                  .setPosition(600,490)
                   .setSize(50,12)
                   ;
*/  
/////////////// Serial Connection Drop Down List ///////////////
  gSerialDdl = cp5.addDropdownList("gSerialPortIndex")
                  .setPosition(435,500)
                  .setSize(160,80)
                  ;
                              
   for(int i=0;i<Serial.list().length;i++)        // add list of serial ports 
      gSerialDdl.addItem(Serial.list()[i],i);
  
  gSerialDdl.setValue(0);                         // initialize with the first port
////////////////////////////////////////////////////////////////
      
  gFreeRAMTl = cp5.addTextlabel("gFreeRAM")
                  .setText("Free RAM [bytes]: N/A")
                  .setPosition(10,580)
                  .setColorValue(0xffffffff)
                  ;

  gLoopTimeTl = cp5.addTextlabel("gLoopTime")
                  .setText("Loop Time [ms]: N/A")
                  .setPosition(150,580)
                  .setColorValue(0xffffffff)
                  ;
      
  gActiveProfileIdTl = cp5.addTextlabel("gActiveProfileId")
                          .setText("Active Profile: N/A")
                          .setPosition(280,580)
                          .setColorValue(0xffffffff)
                          ;

  gFlightTimerSecTl = cp5.addTextlabel("gFlightTimerSec")
                          .setText("Flight Timer [sec]: N/A")
                          .setPosition(430,580)
                          .setColorValue(0xffffffff)
                          ;        
                          
}

/*
void gConnect(int theValue)
{
  println("Connect Button was pressed");
   
  try 
  {
    println("trying to connect to " +  int(gSerialDdl.getValue())); 
    gSerialPort.stop();
    gSerialPort = new Serial(this, Serial.list()[int(gSerialDdl.getValue())], 9600);
  }
  catch (Exception e)
  {
    gSerialPortIndex=-1;
  }
}
*/

// Load-Button was pressed
void gLoad(int theValue)
{
  
  // Request Device Properties
  gSerialPort.write(0xFE);
  gSerialPort.write(0xFE);
  gSerialPort.write(0x43);  // DevicePropertiesReq
  gSerialPort.write(0x00);  // Dummy

  // Request Profile Data
  gSerialPort.write(0xFE);
  gSerialPort.write(0xFE);
  gSerialPort.write(0x41);  // ProfileDataReq
  gSerialPort.write(0x00);  // Dummy (will be used for ProfileId lateron)
  
}

// Load-Button was pressed
void gApply(int theValue)
{
  
  SendProfileData();
  SendDeviceProperties();
  
}


void gSave(int theValue)
{
  
  // Request Device Properties
  gSerialPort.write(0xFE);
  gSerialPort.write(0xFE);
  gSerialPort.write(0x99);  // Save Config to EEPROM
  gSerialPort.write(0x00);  // Dummy

}

void ExtractReceivedProfileData(byte[] aMsg)
{
  // Expo & DualRate values
  for(int axis=0;axis<AXES;axis++) // AIL, ELE, RUD
  {
    for (int fm=0;fm<FLIGHTMODES;fm++)
    {
      gExpNb[axis][fm].setValue(aMsg[fm+3+axis*FLIGHTMODES]);    
      gDRNb[axis][fm].setValue((aMsg[fm+3+AXES*FLIGHTMODES+axis*FLIGHTMODES] & 0xFF));
    }
  }
  
  gV_A1Nb[0].setValue(aMsg[39] & 0xFF);
  gV_A1Nb[1].setValue(float(aMsg[40])/10);
  gV_A1Nb[2].setValue(float(aMsg[41])/10);

  gV_A2Nb[0].setValue(aMsg[42] & 0x0F);
  gV_A2Nb[1].setValue(float(aMsg[43])/10);
  gV_A2Nb[2].setValue(float(aMsg[44])/10);
  gV_A2Nb[3].setValue(byte((aMsg[42] & 0xF0) >> 4));
  
  
  // extract values from byte array
  gFlightTimerNb.setValue((aMsg[46] & 0xFF)*256 + (aMsg[45] & 0xFF));
  
  for (int i=0;i<8;i++)
  {
    if (gChannelLayoutCharToIndexMap.containsKey(char(aMsg[i+47])))
      gChannelDdl[i].setValue(gChannelLayoutCharToIndexMap.get(char(aMsg[i+47]))); 
    else
      gChannelDdl[i].setValue(9); // set to " - " in case not found
  }
}


void SendProfileData()
{
  byte[] tMsg = new byte[53+3];
  
  tMsg[0] = byte(0xFE & 0xFF);
  tMsg[1] = byte(0xFE & 0xFF);
  tMsg[2] = byte(0x42 & 0xFF);
  
  
  // Expo & DualRate values
  for(int axis=0;axis<AXES;axis++) // AIL, ELE, RUD
  {
    for (int fm=0;fm<FLIGHTMODES;fm++)
    {
      tMsg[fm+3+axis*FLIGHTMODES]=byte(gExpNb[axis][fm].getValue());    
      tMsg[fm+3+AXES*FLIGHTMODES+axis*FLIGHTMODES]=byte(gDRNb[axis][fm].getValue());
    }
  }
  
  tMsg[39]=byte(gV_A1Nb[0].getValue());
  tMsg[40]=byte(gV_A1Nb[1].getValue()*10);
  tMsg[41]=byte(gV_A1Nb[2].getValue()*10);

  tMsg[42]=byte(byte(gV_A2Nb[0].getValue()) + byte(byte(gV_A2Nb[3].getValue()) << 4));   // bit 0-3: cell count, bit 4-7: voltage divider ratio
  tMsg[43]=byte(gV_A2Nb[1].getValue()*10);
  tMsg[44]=byte(gV_A2Nb[2].getValue()*10);
  
  
  // extract values from byte array
  tMsg[45]=byte(int(gFlightTimerNb.getValue()) & 0xFF);
  tMsg[46]=byte(int(gFlightTimerNb.getValue()) >> 8);

  
  for (int i=0;i<8;i++)  //################
  {
      tMsg[i+47]=byte(gChannelLayoutChar[int(gChannelDdl[i].getValue())]); 
  }
  
  tMsg[55]=0; // character array is 0-terminated...
  
  for (int i=0;i<tMsg.length;i++)
  {
    println(i + ":" + hex(byte(tMsg[i] & 0xFF)));
    gSerialPort.write(tMsg[i]);
  }
  
  
}



void ExtractReceivedDeviceProperties(byte[] aMsg)
{
  for(int a=0;a<8;a++)    // analog 0-7
  {
    for(int i=0;i<3;i++)  // min, mid, max
    {      
      gAnalogCalibrationNb[a][i].setValue((aMsg[a*7+4+i*2] & 0xFF)*256+ (aMsg[a*7+3+i*2] & 0xFF));
    }
    
    if (aMsg[(a+1)*7+2]==1) 
      gAnalogReverseCb.activate(a);     
  }
  
  for(int i=0;i<3;i++)
  {
    if (aMsg[i+59]==1)
      gSwitchReverseCb.activate(i); 
  }
  
  gV_TXNb[0].setValue(aMsg[62] & 0xFF);
  gV_TXNb[1].setValue(float(aMsg[63])/10);
  gV_TXNb[2].setValue(float(aMsg[64])/10);

  gRSSINb[0].setValue(aMsg[65]);
  gRSSINb[1].setValue(aMsg[66]);
  
  gTelemetryIntervalNb.setValue(aMsg[67]);
 
  gThrottleTimerThresholdNb.setValue(aMsg[68]);
  
  for(int i=0;i<6;i++)    // vfm-steps
  {
    gVFMSwitchLevelsNb[i].setValue((aMsg[i*2+70])*256+ (aMsg[i*2+69] & 0xFF));
  }

    if (aMsg[81]==1) 
      gFlightModeSwitchRb.activate(0);     
    else
      gFlightModeSwitchRb.activate(1);     
    
    if (aMsg[82]==1) 
      gPrimaryProfileSwitchRb.activate(0);   
    else
      gPrimaryProfileSwitchRb.activate(1);   
}

void SendDeviceProperties()
{
  byte[] tMsg = new byte[80+3];
  
  tMsg[0] = byte(0xFE & 0xFF);
  tMsg[1] = byte(0xFE & 0xFF);
  tMsg[2] = byte(0x44 & 0xFF);
  
//  println("sending device properties...");

  for(int a=0;a<8;a++)    // analog 0-7
  {
    for(int i=0;i<3;i++)  // min, mid, max
    {      
      tMsg[a*7+3+i*2]=byte(int(gAnalogCalibrationNb[a][i].getValue())  & 0xFF);
      tMsg[a*7+4+i*2]=byte(int(gAnalogCalibrationNb[a][i].getValue()) >> 8);
    }
 
    if (gAnalogReverseCb.getState(a))    
      tMsg[(a+1)*7+2]=1; 
  }  
  
  
  for(int i=0;i<3;i++)
  {
    if (gSwitchReverseCb.getState(i))
      tMsg[i+59]=1; 
  }
  
  tMsg[62]=byte(gV_TXNb[0].getValue());
  tMsg[63]=byte(gV_TXNb[1].getValue()*10);
  tMsg[64]=byte(gV_TXNb[2].getValue()*10);

  tMsg[65]=byte(gRSSINb[0].getValue());
  tMsg[66]=byte(gRSSINb[1].getValue());
  
  tMsg[67]=byte(gTelemetryIntervalNb.getValue());
 
  tMsg[68]=byte(gThrottleTimerThresholdNb.getValue());
 
  for(int i=0;i<6;i++)    // vfm-steps
  {
    tMsg[i*2+69]=byte(int(gVFMSwitchLevelsNb[i].getValue())   & 0xFF);
    tMsg[i*2+70]=byte(int(gVFMSwitchLevelsNb[i].getValue()) >> 8);
    
  }
  
  if (gFlightModeSwitchRb.getState(0))
    tMsg[81]=1; 
  else
    tMsg[81]=0; 
  
  if (gPrimaryProfileSwitchRb.getState(0))
    tMsg[82]=1; 
  else
    tMsg[82]=0;
    
  
  for (int i=0;i<tMsg.length;i++)
  {
//    println(i + ":" + (tMsg[i] & 0xFF));
    gSerialPort.write(tMsg[i]);
  } 
}



void ExtractRealTimeData (byte[] aMsg)
{
  for(int i=0;i<8;i++)
  {
    gAnalogSl[i].setValue((aMsg[i*2+4] & 0xFF)*256+ (aMsg[i*2+3] & 0xFF));
    gChannelSl[i].setValue((aMsg[i*2+20] & 0xFF)*256+ (aMsg[i*2+19] & 0xFF));
  }
  
  gSW1StateRb.activate(aMsg[35]);
  gSW2StateRb.activate(aMsg[36]);
  gSW3StateRb.activate(aMsg[37]);
  gActiveProfileIdTl.setText("Active Profile: " + (aMsg[38]+1));
  gCurrentFlightModeTl.setText("Active Flightmode: "+ (aMsg[39]+1));
  gFreeRAMTl.setText("Free RAM [bytes]: "+ (int(aMsg[41] & 0xFF)*256 + (aMsg[40] & 0xFF)));
  gLoopTimeTl.setText("Loop Time [ms]: "+ (int(aMsg[43] & 0xFF)*256 + (aMsg[42] & 0xFF)));
  gFlightTimerSecTl.setText("Flight Timer [sec]:" + (int(aMsg[45] & 0xFF)*256 + (aMsg[44] & 0xFF)));
}



void draw() {
  background(0);

  byte byteRead=0;
  
  if (gSerialPortIndex > -1)
  {
    while ( gSerialPort.available() > 0) 
    {                                                  // If data is available,
      byteRead = byte(gSerialPort.read());             // read it and store it in val
      
//      print(byteCount);
//      println(": " + byteRead);
     
      if      ((byteCount==0) && ((byteRead & 0xFF)==0xEF))    Buffer[byteCount++]=byteRead;                                   // first header byte
      else if ((byteCount==1) && ((byteRead & 0xFF)==0xEF))    Buffer[byteCount++]=byteRead;                                   // 2nd header byte
      else if ((byteCount==2) && ((byteRead==0x01) || (byteRead==0x02) || (byteRead==0x03)))   Buffer[byteCount++]=byteRead;   // valid message ID?
      else if (byteCount>2)
      {
        switch (Buffer[2])
        {
          case 0x01:         // Message Id 0x01 (ProfileData)
//            println("Profile data");
//       print(byteCount);
//       println(": " + (byteRead & 0xFF));  
            if (byteCount<(53+2))                
              Buffer[byteCount++]=byteRead;
            else
            {
               Buffer[byteCount]=byteRead;
               byteCount=0;
//               println("Message complete.");
               ExtractReceivedProfileData(Buffer);
            }          
          
            break;



          case 0x02:         // Message Id 0x02 (Realtime data)
//            println("Realtime data");
//       print(byteCount);
//       println(": " + byteRead);
            if (byteCount<(43+2))                
              Buffer[byteCount++]=byteRead;
            else
            {
               Buffer[byteCount]=byteRead;
               byteCount=0;
//               println("Message complete.");
               ExtractRealTimeData(Buffer);
            }
            break;
  



          case 3:         // Message Id 0x03 (DeviceProperties)
//            println("Device Properties");
//       print(byteCount);
//       println(": " + (byteRead & 0xFF));
            if (byteCount<(80+2))                
            {
              Buffer[byteCount++]=byteRead;
            }
            else
            {
               Buffer[byteCount]=byteRead;
               byteCount=0;
//               println("Message complete.");
               ExtractReceivedDeviceProperties(Buffer);
            }
            break;
          
          
          
          default:
          println("Unknown MessageId");
          byteCount=0;
          
        }
      }
    }
  }
}




void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) 
  {
    // check if the Event was triggered from a ControlGroup

   if(theEvent.group().getName()=="gSerialPortIndex")
   {
      gSerialPortIndex=int(theEvent.getGroup().getValue());
//      println("Selected Serial: " + gSerialPortIndex);
      
      try 
      {
//        println("trying to connect to " +  int(gSerialDdl.getValue())); 
        gSerialPort.stop();
        gSerialPort = new Serial(this, Serial.list()[int(gSerialPortIndex)], 9600);

        delay(2500);
        gLoad(1); // request device properties and profile data from Tx
      }
      catch (Exception e)
      {
        gSerialPortIndex=-1;
      }
    }
  } 
  else if (theEvent.isController()) 
  {
//    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
  
   

}





