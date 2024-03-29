@echo off
REM CONFIGURATION
SET prefix=.
SET AVR_CPP=%prefix%\hardware\tools\avr\bin\avr-g++.exe
SET AVR_GCC=%prefix%\hardware\tools\avr\bin\avr-gcc.exe  
SET AVR_AR=%prefix%\hardware\tools\avr\bin\avr-gcc-ar.exe
SET AVR_AS=%prefix%\hardware\tools\avr\bin\avr-as.exe
SET AVR_RANLIB=%prefix%\hardware\tools\avr\bin\avr-ranlib.exe
SET dir=%prefix%\hardware\arduino\avr
SET ldir=%prefix%\libraries
SET ts=%ldir%\TS
SET ldir2=%prefix%\hardware\arduino\avr\libraries

ECHO %time%
DEL %prefix%\core\*.* /q

ECHO "GENERATION DE WIRE_PULSE ASM"
%AVR_GCC% -c -g -x assembler-with-cpp -flto -MMD -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10801 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I%dir%/cores/arduino -I%dir%/variants/standard -o core/wiring_pulse.S.o %dir%\cores\arduino\wiring_pulse.S
ECHO "COMPILATION DES FICHIERS CORE ARDUINO"
for %%v in ( %dir%\cores\arduino\*.c ) do (
  ECHO %%v
  %AVR_GCC% -c -g -Os -w -std=gnu11 -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10801 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I%dir%\cores\arduino -I%dir%\variants\standard -o %%v.o %%v
)
for %%v in ( %dir%\cores\arduino\*.cpp ) do (
  ECHO %%v
  %AVR_CPP% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10801 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I%dir%\cores\arduino -I%dir%\variants\standard -o %%v.o %%v
)

for %%v in ( %dir%\cores\arduino\*.o ) do (
  ECHO %%v  
  MOVE %%v  ./core/
)

for %%v in ( %dir%\cores\arduino\*.d ) do (
  ECHO %%v  
  MOVE %%v  ./core/
)

ECHO "Compilation de la lib TS"
for %%v in ( %ts%\*.cpp ) do (
  ECHO %%v
  %AVR_CPP% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10801 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I%dir%\cores\arduino -I%dir%\variants\standard -I%ts% -I%ldir2%/Wire -I%ldir2%/Wire/utility/ -I%ldir2%/SoftwareSerial -o %%v.o %%v
)

for %%v in ( %ts%\*.o ) do (
  ECHO %%v  
  MOVE %%v  ./core/
)

for %%v in ( %ts%\*.d ) do (
  ECHO %%v  
  MOVE %%v  ./core/
)



ECHO "GENERATION DE SOFTSERIAL"
%AVR_CPP% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10801 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I%dir%/cores/arduino -I%dir%/variants/standard -I%ldir2%/SoftwareSerial -o core/SoftwareSerial.o %ldir2%/SoftwareSerial/SoftwareSerial.cpp

echo "Génération de TWI WIRE"
%AVR_GCC% -c -g -Os -w -std=gnu11 -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10801 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I%dir%/cores/arduino -I%dir%/variants/standard -I%ldir2%/Wire -I%ldir2%/Wire/utility/ -o core/twi.o %ldir2%/Wire/utility/twi.c
echo "Génération de WIRE"
%AVR_CPP% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -MMD -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10801 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I%dir%/cores/arduino -I%dir%/variants/standard -I%ldir2%/Wire -I%ldir2%/Wire/utility/ -o core/Wire.o %ldir2%/Wire/Wire.cpp
ECHO "ASSEMBLAGE DE LA BIBLIOTHEQUE"
%AVR_AR% rcsv core/core.a core/*.o
echo %time%
:eof

