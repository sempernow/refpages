# Radio : [PMR](https://chatgpt.com/share/671cfc17-1484-8009-91d5-497890198fee "ChatGPT") (Personal/Professional Mobile Radio)

Narrowband (typically 12.5 KHz of UHF) communication systems for voice and data.

## Examples

1. [TP9500](MPT-1327-radio-TAIT.TP9500.jpg)  
_The TP9500 supports multiple modes. Analog Conventional, MPT Trunking, DMR Tier 2 Conventional, and DMR Tier 3 Trunking_
    ```plaintext
    Available:
        VHF: 136-174MHz,
        UHF: 378-470MHz (H5), 450-520MHz (H7), 762-870MHz
    Output:
        3W
    Channels/Zones:
        1,500 channels / 26 zones and 16 channels 
    ```
1. [DMR-6x2](https://baofengtech.com/product/dmr-6x2/ "BaofengTech.com") | Kit @ [RadioMadeEasy.com](https://radiomadeeasy.com/product/wranglerstar-proho-radio-package/)  
_BTECH DMR-6X2 DMR & Analog Dual Band Two-Way Radio-7W VHF/UHF (136-174MHz & 400-480MHz), Encryption, GPS, Talker Alias, Voice Recording, with Large Accessory Kit_

## [PMR446](https://en.wikipedia.org/wiki/PMR446 "Wikipedia.org")

__Private Mobile Radio, 446MHz__ is a licence-exempt UHF-band service available for business and personal use in most countries throughout the EU. The __European__ equivalent to US/Canada's FRS.

## [FRS](https://en.wikipedia.org/wiki/Family_Radio_Service "Wikipedia.org") (Family Radio Service)

A __personal radio service__ in __USA__ intended for families and individuals. 
FRS is the USA equivalent of EU's PMR446.

FRS radios use narrow-band FM.

22 Channels 

12.5 kHz channel spacing (used in land mobile frequency bands globally)

0.5W per channel.

2.0W @ Channels 1-7, 15-22.

FRS/GMRS hybrids exist due to their [overlapping frequency bands](GMRS_and_FRS_Frequency_Spectrum_Chart.png).

## [GMRS](https://en.wikipedia.org/wiki/General_Mobile_Radio_Service "Wikipedia.org") (General Mobile Radio Service)

A __personal radio service__ intended for families and individuals. It's popular for short-range, personal, or recreational communication and does not require specialized knowledge or equipment. GMRS radios can be used without a business license, but they do require an FCC license in the U.S.

License required; 1 per family. 

UHF frequencies in the 462-467 MHz range with analog FM modulation.

Land-mobile FM UHF radio service designed for short-range two-way voice communication

## [Trunked Radio System](https://en.wikipedia.org/wiki/Trunked_radio_system "Wikipedia.org")s

Digital radio is required.

A trunked radio system is a [packet-switching](https://en.wikipedia.org/wiki/Packet_switching) network, forming a two-way radio, that uses a __control channel__ to automatically assign frequency channels to groups of user radios. In a traditional half-duplex land mobile radio system a group of users (__talkgroup__) with mobile and portable two-way radios communicate over a single shared radio channel, with one user at a time talking. 

### [MPT-1327](https://en.wikipedia.org/wiki/MPT-1327 "Wikipedia.org") | [RadioReference.com](https://wiki.radioreference.com/index.php/MPT-1327) 

Legacy ___analog___ [trunked radio communication networks](https://en.wikipedia.org/wiki/Trunked_radio_system "Wikipedia.org") standard create in 1988 by UK's Ministry of Posts and Telegraph (MPT).

Primarily used in the UK, Europe, SA, Australia, New Zealand and China. Many countries had their own version of number/user interface, including __MPT1343__ in the UK, __Chekker__ (Regionet 43) in Germany, __3RP__ (CNET2424) in France, __Multiax__ in Australia, and __Gong An__ in China.

MPT systems are still being built in many areas of the world, due to their cost-effectiveness. 

### [P25](https://en.wikipedia.org/wiki/Project_25 "Wikipedia.org") AKA Project 25 AKA <dfn title="Association of Public-Safety Communications Officials-International">APCO</dfn>-25

Developed by public safety professionals in North America. Fragmented/Bureucratic per metropolis. Now has broader application worldwide, though mostly USA. P25 is __digital replacement for analog UHF__ (typically FM) radios, adding the __ability to transfer data__ as well as voice for more natural implementations of encryption and text messaging. P25 radios are commonly implemented by dispatch organizations, such as __police__, __fire__, __ambulance__ and __ERS__ (Emergency Rescue Service), using vehicle-mounted radios combined with repeaters and handheld walkie-talkie use.

- P25 Phase 1 : Modulation protocol pre-2012; voice only; 1 channel.
- P25 Phase 2 : Modulation protocol 2012+; voice + data.; more advanced AMBE2+ vocoder, which allows audio to pass through a more compressed bitstream and provides two TDMA voice channels in the same RF bandwidth (12.5 kHz).

The two protocols are not compatible, but Phase 2 radios are backwards compatible with phase 1 modulation and analog FM modulation, per the standard.
P25 Phase 2 infrastructure can provide a "dynamic transcoder" feature that __translates between Phase 1 and Phase 2__ as needed. 

EU has created __TETRA__ (Terrestrial Trunked Radio) and __DMR__ (Digital Mobile Radio) protocol standards, which fill a similar role to P25. 

#### P25 open interfaces

P25's Suite of Standards specify eight open interfaces between the various components of a land mobile radio system. These interfaces are:

- Common Air Interface (__CAI__) – standard specifies the type and content of signals transmitted by compliant radios. One radio using CAI should be able to communicate with any other CAI radio, regardless of manufacturer
- Subscriber Data Peripheral Interface – standard specifies the port through which mobiles and portables can connect to laptops or data networks
- Fixed Station Interface – standard specifies a set of mandatory messages supporting digital voice, data, encryption and telephone interconnect necessary for communication between a Fixed Station and P25 RF Subsystem
- Console Subsystem Interface – standard specifies the basic messaging to interface a console subsystem to a P25 RF Subsystem
- Network Management Interface – standard specifies a single network management scheme which will allow all network elements of the RF subsystem to be managed
- Data Network Interface – standard specifies the RF Subsystem's connections to computers, data networks, or external data sources
- Telephone Interconnect Interface – standard specifies the interface to Public Switched Telephone Network (__PSTN__) supporting both analog and __ISDN__ telephone interfaces.
- Inter RF Subsystem Interface (__ISSI__) – standard specifies the interface between RF subsystems which will allow them to be connected into wide area networks


Same/Similar systems : 

- GRN (Government Radio Network) : Australia, New South Wales, South Australia, and Tasmania
    - PSN (Public Safety Network) : New South Wales
- GWN (Government Wireless Network) : Queensland
- TRN (Territory Radio Network) : Australian Capital Territory; 
- MMR (Melbourne Metropolitan Radio) : Victoria
- RMR (Rural Mobile Radio) : Victoria.

### [DMR](https://en.wikipedia.org/wiki/Digital_mobile_radio "Wikipedia.org") (Digital Mobile Radio)

#### Overview

A digital radio standard requiring an FCC license on specific frequencies. Designed for professional, commercial, and public safety applications. It’s used by organizations that need reliable, high-quality communications over a wider area and with advanced capabilities like dispatch, location tracking, and emergency calling. It's often integrated into professional networks or __used by licensed amateur radio operators__ on amateur bands.

Conventional (Direct) and Trunked modes.

DMR is a digital replacement for analogue PMR (Private Mobile Radio).

An <dfn title="European Telecommunications Standards Institute">[ETSI](https://www.etsi.org/technologies/mobile-radio "ETSI.org")</dfn> standard.

30 MHz - 1 GHz

12.5 kHz channel spacing (used in land mobile frequency bands globally)

Two voice channels through two-slot TDMA technology.

The PMR/DMR markets can be roughly divided into three broad categories:

#### Tiers

- __Tier I__ : Consumer and short-range industrial. 
  Max 0.5W; forbids repeaters; licence-free in European PMR446 band; uses TMDA (typically). 
    - Baofeng and others may mis-label as DMR Tier I, yet use frequencies beyond PMR446 licence–free, and have max power beyond that allowed.
- __Tier II__ : Professional / Business-Critical applications.  
  66–960 MHz, two slot TDMA in 12.5 kHz channels; __advanced voice features and integrated IP data services in licensed bands for high-power communications__. [BTECH DMR 6X2](https://www.amazon.com/BTECH-DMR-6X2-136-174MHz-400-480MHz-Programming/dp/B076H96BDC/ref=sr_1_1)
- __Tier III__ : Public Safety / Mission-Critical applications.  
    Same radio spec as Tier II. Supports voice and short messaging handling similar to TETRA with built-in 128 character status messaging and short messaging with up to 288 bits of data in a variety of formats. It also supports packet data service in a variety of formats, including support for IPv4 and IPv6. 

#### DMR interface

ETSI standards:

- TS 102 361-1: Air interface protocol
- TS 102 361-2: Voice and General services and facilities
- TS 102 361-3: Data protocol
- TS 102 361-4: Trunking protocol

#### Channels / Licensing 

DMR operates in shared VHF (136-174 MHz) and UHF (403-527 MHz) bands, but specific channel access is controlled through licensing. In most countries, government agencies (like the FCC in the U.S.) allocate portions of these bands for public safety, government, commercial, and private business use.

- __Public Safety and Government__:  
    Access is restricted and carefully licensed.
- __Business and Industrial__:  
    Licenses are available for private DMR networks 
    with FCC approval and frequency coordination.
- __Amateur Radio Operators__:  
    Licensed "hams" can use DMR on the 
    [70 cm band](https://en.wikipedia.org/wiki/70-centimeter_band "Wikipedia.org") 
    (420-450 MHz) for non-commercial, personal communication without coordination, 
    provided they follow amateur radio regulations.
    - Also [ATV](https://en.wikipedia.org/wiki/Amateur_television) (Amateur Television).

DMR is used on the __amateur radio__ VHF and UHF bands. Coordinated DMR __Identification Numbers__ are assigned and __managed by RadioID Inc__. Their coordinated database can be uploaded to DMR radios in order to display the name, call sign, and location of other operators. 

#### Repeaters / Hotspots 

Internet-linked systems such as DV Scotland Phoenix Network, __BrandMeister__ network, TGIF, __FreeDMR__ and several others __allow users to communicate with other users around the world__ via connected repeaters, or (RPi) DMR "hotspots". 

There are __currently more than 5,500 repeaters and 16,000 "hotspots"__ linked to the __BrandMeister__ system worldwide. The low-cost and increasing availability of internet-linked systems has led to a rise in DMR use on the amateur radio bands. Some Raspberry Pi-based DMR hotspots, often those running the [__Pi-Star__](https://www.pistar.uk/ "PIstar.uk") software, allow users to connect to multiple internet-linked DMR networks at the same time. DMR hotspots are often based on the FOSS Multimode Digital Voice Modem (__MMDVM__), hardware with firmware.

### [TETRA](https://en.wikipedia.org/wiki/TETRA "Wikipedia.org") (Terrestrial Trunked Radio formerly Trans-European Trunked Radio)  

An <dfn title="European Telecommunications Standards Institute">[ETSI](https://www.etsi.org/technologies/mobile-radio "ETSI.org")</dfn> standard deployed in sixty countries, and the preferred choice in Europe, China, and other countries. 

TETRA uses a four-slot TDMA in a 25 kHz channel of 
a [trunked radio system](https://en.wikipedia.org/wiki/Trunked_radio_system "Wikipedia.org")

 TETRA terminals can act as mobile phones (cell phones), 
 with __a full-duplex direct connection to other TETRA Users or the PSTN__.

### [NXDN](https://en.wikipedia.org/wiki/NXDN "Wikipedia.org") (Next Generation Digital Narrowband)

Conventional and Trunked modes. Conventional is called  Direct Mode Operation (__DMO__).

In DMO, TETRA radios operate more like traditional two-way radios in a peer-to-peer or simplex setup. It’s commonly used by first responders and organizations needing direct communication when infrastructure is unavailable.

## [Marine VHF Radio](https://en.wikipedia.org/wiki/Marine_VHF_radio "Wikipedia")

Emergency radio for ships; a worldwide system of two way radio transceivers on ships and watercraft used for bidirectional voice communication from ship-to-ship, ship-to-shore (for example with harbormasters), and in certain circumstances ship-to-aircraft. 

It uses FM channels in VHF band (156 and 174 MHz), designated by the <dfn title="International Telecommunication Union">ITU</dfn> as the __VHF maritime mobile band__. In some countries additional channels are used, such as L and F channels for leisure and fishing vessels in the Nordic countries (at 155.5–155.825 MHz). Transmitter power is limited to __25 watts__, giving them a range of about __100 kilometres__ (62 mi; 54 nmi).

Marine VHF radio equipment is installed on all large ships and most seagoing small craft. It is also used, with slightly different regulation, on rivers and lakes. It is used for a wide variety of purposes, including marine navigation and traffic control, summoning rescue services and communicating with harbours, locks, bridges and marinas. 

- __Channel 16 (156.8 MHz)__:  
    VHF Channel 16 is the international distress, safety, 
    and calling channel and is __monitored continuously__ by the Coast Guard and other vessels. 
    It is used for initial distress calls, mayday signals, and other urgent communications.

- __Digital Selective Calling (DSC)__:  
    Modern VHF marine radios are equipped with DSC capability, 
    which enables a boat operator to send an __automated distress signal by pressing a button__. 
    The DSC signal includes the vessel’s identity and, 
    if linked to a GPS, its location, making it faster and more reliable for alerting rescuers.
    DSC calls on __Channel 70__ serve as an automated emergency alert 
    and reduce the time needed to reach help in an emergency.

- __Automatic Identification System (AIS)__:  
    Some VHF radios also include AIS capability, 
    which can provide __vessel identification and location__ information in real time, 
    improving safety and coordination in busy waters. 
    This isn’t solely for emergency use 
    but can be valuable in __collision avoidance__ and locating vessels in distress.

- __EPIRB__ and __PLB__ Devices (__Beacons__):  
    While VHF radios are standard for emergency communication, 
    many vessels also carry Emergency Position-Indicating Radio Beacons (EPIRBs) or Personal Locator Beacons (PLBs). 
    These devices operate on __satellite frequencies__ (406 MHz) 
    and can send a distress signal globally, even __beyond the VHF range__.

### &nbsp;

<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->


## [Amateur (Ham) Radio](https://en.wikipedia.org/wiki/Amateur_radio "Wikipedia.org") AKA Amateur Radio Service

### [Q code](https://en.wikipedia.org/wiki/Q_code) 

A collection of 3-letter codes developed as operating signals for 
[Morse Code](https://en.wikipedia.org/wiki/Morse_code "Wikipedia.org"). 
Q code messages can stand for either a statement or a question. Example query/answer:

#### Q: '`QSL?`'

Means "Do you confirm receipt of my transmission?"

#### A: '`QSL`'

Means "I confirm receipt of your transmission."

#### First twelve Q-codes 

Listed in the 1912 International Radiotelegraph Convention:

```plaintext
Code       Question                             Answer or notice

QRA        What ship or coast station is that?  This is ____.
QRB        What is your distance?               My distance is ____.
QRC        What is your true bearing?           My true bearing is ____ degrees.
QRD        Where are you bound for?             I am bound for ____.
QRF        Where are you bound from?            I am bound from ____.
QRG        What line do you belong to?          I belong to the ____ Line.
QRH        What is your wavelength in meters?   My wavelength is ____ meters.
QRJ        How many words have you to send?     I have ____ words to send.
QRK        How do you receive me?               I am receiving (1–5). (5) is perfect.
QRL        Are you busy?                        I am busy.
QRM        Are you being interfered with?       I am being interfered with.
QRN        Are the atmospherics strong?         Atmospherics (noise) are very strong. 
```

#### Listing according to service

```plaintext
QAA to QNZ – Assigned by the International Civil Aviation Organization (ICAO).
QNA to QNZ – ARRL developed its own QN Signals for message handling. 
                (They overlap with other signals.)
QOA to QQZ – For the Maritime Mobile Service.
QRA to QUZ – Assigned by ITU Radiocommunication Sector (ITU-R).
```

#### All services (`QRA–QUZ`)

```plaintext
Code       Question                         Answer or notice
...
QRZ        Who is calling me?               You are being called by ____ (on ____ kHz (or MHz)). 
...
QSL        Can you acknowledge receipt?     I am acknowledging receipt. 
...
```

#### [QSL Card](https://en.wikipedia.org/wiki/QSL_card)

A written confirmation of either a two-way radiocommunication between two amateur radio or citizens band stations; a one-way reception of a signal from an AM radio, FM radio, television or shortwave broadcasting station; or the reception of a two-way radiocommunication by a third party listener. See Q-code list above for details of the `QSL` reference.

A typical QSL card is the same size and material as a typical __postcard__, 
and most are sent through the mail as such.


### [FCC Examinations](https://hamradioprep.com/ham-radio-study-guide/) for Radio License Levels

- [ARRL](http://www.arrl.org/) (American Radio Relay League)
- [Ham Radio Prep](https://hamradioprep.com/ham-radio-study-guide/) | [Forums.QRZ.com](https://forums.qrz.com/index.php?threads/the-visionary-behind-ham-radio-prep-world-radio-league.933075/)
    - [Free Practice Test](https://hamradioprep.com/free-ham-radio-practice-tests/)
- [FCC Examinations](https://www.fcc.gov/wireless/bureau-divisions/mobility-division/amateur-radio-service/examinations)

- __Level 1: FCC Technician License__  
    This license introduces you to radio, electronics, safety and related operating rules.  Passing this exam grants a license which __allows you to operate on all amateur radio frequencies above 30 MHz__. 
    ```plaintext
    Topic   Group Name 	                Questions

    T1      FCC Rules and Regulations   6
    T2      Operating Procedures        3
    T3      Radio Wave Propagation      3
    T4      Amateur Radio Practices     2
    T5      Electrical Principles       4
    T6      Electrical Components       4
    T7      Practical Circuits          4
    T8      Signals and Emissions       4
    T9      Antennas and Feed Lines     2
    T0      Safety                      3

    Total                              35
    ```


- __Level 2: FCC General License__  
    This license expands your knowledge of radio operating, covers radio frequency theory for HF operation and additional electronics knowledge.  Achieving the General Class license __allows you to operate in parts of all amateur radio frequencies__. You are required to have passed the Technician license exam.
- __Level 3: FCC Amateur Extra License__ 
    To reach the highest level of ham radio license you’ll deep dive into additional RF and electronics theory.  When you finish, __you earn the privileges of unique operating frequencies on the HF bands__, the ability to __operate easily from other countries__, and the right to __become a Volunteer Examiner__.  You can not become an Amateur Extra without passing the Technician and General exams.