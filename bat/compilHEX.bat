@ECHO OFF
CLS
set NLM=^


set NL=^^^%NLM%%NLM%^%NLM%%NLM%
SET projet=default
SET serie=COM3
SET baud=115200
SET options=-c -g -Os -w -fno-exceptions -ffunction-sections -fdata-sections -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=22
SET prefix=.
SET AVR_CPP=%prefix%\hardware\tools\avr\bin\avr-c++.exe
SET AVR_GCC=%prefix%\hardware\tools\avr\bin\avr-gcc.exe  
SET AVR_AR=%prefix%\hardware\tools\avr\bin\avr-ar.exe
SET AVR_OBJCOPY=%prefix%\hardware\tools\avr\bin\avr-objcopy.exe
SET dir=%prefix%\hardware\arduino\avr
SET ldir=%prefix%\libraries
SET ts=%ldir%\TS
SET ldir2=%prefix%\hardware\arduino\avr\libraries
echo %time%
DEL prod\%projet%.*
echo #include "Arduino.h"%NL%  > prod\%projet%.cpp
echo "PATCH DE ./ino/%projet%.ino vers prod\%projet%.cpp"
copy /B prod\%projet%.cpp + .\ino\%projet%.ino prod\%projet%.cpp

ECHO "COMPILATION DU PROJET"
%AVR_CPP% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10801 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I%dir%\cores\arduino -I%dir%\variants\standard -I%ldir2%/Wire -I%ldir2%/Wire/utility/ -I%ldir2%/SoftwareSerial -I%ts% -o prod\%projet%.o prod\%projet%.cpp 

ECHO "Edition des liens"
%AVR_GCC% -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=atmega328p -o "prod\%projet%.elf" "prod\%projet%.o" "core\core.a" "-Lcore" -lm
echo "Génération du fichier HEX"
%AVR_OBJCOPY% -O ihex -R .eeprom prod\%projet%.elf prod\%projet%.hex
echo %time%