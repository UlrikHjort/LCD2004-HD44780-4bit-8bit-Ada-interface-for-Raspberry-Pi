EXE = main
ADA_VERSION = -gnat12
GPIO_DIR = gpio
GPIO = $(GPIO_DIR)/gpio_raspberrypi.adb 
DISPLAY_DIR = display
DISPLAY = $(DISPLAY_DIR)/hd44780.adb 


SRC = main.adb  $(GPIO) $(DISPLAY) 
INCLUDE = -I$(GPIO_DIR) -I$(DISPLAY_DIR)
FLAGS = -gnato -gnatwa -fstack-check -g

all:
	gnatmake  $(ADA_VERSION) $(FLAGS) $(INCLUDE) $(SRC) 


clean:
	rm *.ali *~ *.o b~* $(EXE)  $(GPIO_DIR)/*~ $(DISPLAY_DIR)/*~
