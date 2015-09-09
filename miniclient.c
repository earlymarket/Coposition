
// Include the GSM library
#include <GSM.h>

#include <stdlib.h>

#define USERAGENT      "Coposition"              // user agent is the project name
#define PINNUMBER ""  

// APN data
#define GPRS_APN       "everywhere" // replace your GPRS APN
#define GPRS_LOGIN     "eesecure"    // replace with your GPRS login
#define GPRS_PASSWORD  "secure" // replace with your GPRS password

// initialize the library instance
GSMClient client;
GPRS gprs;
GSM gsmAccess;

// Input: Pin D2

volatile boolean first;
volatile boolean triggered;
volatile unsigned long overflowCount;
volatile unsigned long startTime;
volatile unsigned long finishTime;

int led = 12;

// here on rising edge
void isr () 
{
 unsigned int counter = TCNT1;  // quickly save it
 
 // wait until we noticed last one
 if (triggered)
   return;

 if (first)
   {
   startTime = (overflowCount << 16) + counter;
   first = false;
   return;  
   }
   
 finishTime = (overflowCount << 16) + counter;
 triggered = true;
 detachInterrupt(4);   
}  // end of isr

// timer overflows (every 65536 counts)
ISR (TIMER1_OVF_vect) 
{
 overflowCount++;
}  // end of TIMER1_OVF_vect


void prepareForInterrupts ()
 {
 // get ready for next time
 EIFR = bit (INTF0);  // clear flag for interrupt 0
 first = true;
 triggered = false;  // re-arm for next time
 attachInterrupt(4, isr, RISING);     
 }  // end of prepareForInterrupts

char server[] = "techlog-api.herokuapp.com";

unsigned long lastConnectionTime = 0;           // last time you connected to the server, in milliseconds
boolean lastConnected = false;                  // state of the connection last time through the main loop
const unsigned long postingInterval = 10*1000;  // delay between updates to Pachube.com


void setup()
{
  digitalWrite(led, HIGH);
  // initialize serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  pinMode(led, OUTPUT);


  // connection state
  boolean notConnected = true;

  // After starting the modem with GSM.begin()
  // attach the shield to the GPRS network with the APN, login and password
  while(notConnected)
  {
    if((gsmAccess.begin(PINNUMBER)==GSM_READY) & // @lexsandeford Not entirely sure what's going on here
        (gprs.attachGPRS(GPRS_APN, GPRS_LOGIN, GPRS_PASSWORD)==GPRS_READY))
      notConnected = false;
    else
    {
      Serial.println("Not connected");
      digitalWrite(led, LOW);
      delay(500);

    }
  }

  Serial.println("Connected to GPRS network");
  Serial.println("Preparing for interrupts.");

  // reset Timer 1
  TCCR1A = 0;
  TCCR1B = 0;
  // Timer 1 - interrupt on overflow
  TIMSK1 = bit (TOIE1);   // enable Timer1 Interrupt
  // zero it
  TCNT1 = 0;  
  overflowCount = 0;  
  // start Timer 1
  TCCR1B =  bit (CS10);  //  no prescaling

  // set up for interrupts
  prepareForInterrupts ();
}

void loop()
{
  if (!triggered)
    return;

  unsigned long elapsedTime = finishTime - startTime;
  float freq = F_CPU / float (elapsedTime);  // each tick is 62.5 ns at 16 MHz

  if (client.available())
  {
    char c = client.read();
    Serial.print(c);
  }

  // if there's no net connection, but there was one last time
  // through the loop, then stop the client
  if (!client.connected() && lastConnected)
  {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
  }

  // if you're not connected, and ten seconds have passed since
  // your last connection, then connect again and send data
  if(!client.connected() && (millis() - lastConnectionTime > postingInterval))
  {

    Serial.print ("Took: ");
    Serial.print (elapsedTime);
    Serial.print (" counts. ");
    Serial.print ("Frequency: ");
    Serial.print (freq);
    Serial.println (" Hz. ");

    Serial.print ("ATTEMPTING TO SEND: ");
    Serial.println (freq);

    char buff[7];
    dtostrf(freq, 4, 3, buff);

    sendData(buff);
  }
  // store the state of the connection for next time through
  // the loop
  lastConnected = client.connected();
}

// this method makes a HTTP connection to the server
void sendData(String thisData)
{
  // if there's a successful connection:
  if (client.connect(server, 80))
  {
    // Output for debugging (can be removed in release)
    Serial.println("connecting...");

    Serial.println();
    Serial.println();

    Serial.print("POST /redbox/checkins");
    Serial.println(" HTTP/1.1");
    Serial.print("Host: ");
    Serial.println(server);
    Serial.print("User-Agent: ");
    Serial.println(USERAGENT);
    Serial.print("Content-Length: ");
    Serial.println(thisData.length());

    Serial.println("Content-Type: text/plain");
    Serial.println("Accept: \*/\*");
    Serial.println("Connection: close");
    Serial.println();

    


    Serial.println(thisData);
    Serial.println();


    // Actual data being sent

    client.print("POST /redbox/checkins");
    client.println(" HTTP/1.1");
    client.print("Host: ");
    client.println(server);
    client.print("User-Agent: ");
    client.println(USERAGENT);
    client.print("Content-Length: ");
    client.println(thisData.length());

    client.println("Content-Type: text/plain");
    client.println("Accept: \*/\*");
    client.println("Connection: close");
    client.println();

    client.print(thisData);
  }
  else
  {
    // if you couldn't make a connection
    Serial.println("connection failed");
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
  }
  // note the time that the connection was made or attempted:
  lastConnectionTime = millis();
  prepareForInterrupts ();   
}
