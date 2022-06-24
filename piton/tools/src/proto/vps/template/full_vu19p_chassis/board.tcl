#####################
# General Information
#####################
set_chassis_prefix U_CHAS
set_slot_prefix U_SLOT
set_fpga_prefix U_
#####################
# Backplane Type
#####################
set_backplane -chassis 1 -type standard

#####################
# Chassis description
#####################
# Description of chassis <1>
add_chassis -id 1

# Description of slots
add_slot -id 1 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 281545
add_slot -id 2 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 281545
add_slot -id 3 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 281545
add_slot -id 4 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 281545
add_slot -id 5 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 281545
add_slot -id 6 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 281545
add_slot -id 7 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 281545
add_slot -id 8 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 281545
add_slot -id 9 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 282080
add_slot -id 10 -rev revB -chassis_id 1 -device VU19P -speedgrade 2 -part_num 281545

# Description of ice modules
add_ice -name ICE_Cube_3 -type nvram_cube -chassis 1 -id 3 -rev 0 -max_rev 1 -min_rev 0
add_ice -name ICE_Cube_4 -type nvram_cube -chassis 1 -id 4 -rev 0 -max_rev 1 -min_rev 0
add_ice -name ICE_Cube_5 -type ethernet_cube -chassis 1 -id 5 -rev 0 -max_rev 1 -min_rev 0

# Description of native ice modules
add_native_ice -name ICE_native_1g_1 -type eth_1g_native -chassis 1 -rev 1 -max_rev 0 -min_rev 0
add_native_ice -name ICE_native_1g_2 -type eth_1g_native -chassis 1 -rev 1 -max_rev 0 -min_rev 0


#####################
# OLINK description
#####################
add_olink -from_chassis 1 -from_slot 8 -from_fpga B -from_link 59 -to_chassis 1 -to_slot 10 -to_fpga B -to_link 57
add_olink -from_chassis 1 -from_slot 8 -from_fpga B -from_link 60 -to_chassis 1 -to_slot 10 -to_fpga B -to_link 58
add_olink -from_chassis 1 -from_slot 8 -from_fpga B -from_link 57 -to_chassis 1 -to_slot 10 -to_fpga B -to_link 59
add_olink -from_chassis 1 -from_slot 8 -from_fpga B -from_link 58 -to_chassis 1 -to_slot 10 -to_fpga B -to_link 60
add_olink -from_chassis 1 -from_slot 1 -from_fpga A -from_link 7 -to_chassis 1 -to_slot 1 -to_fpga B -to_link 43
add_olink -from_chassis 1 -from_slot 1 -from_fpga B -from_link 57 -to_chassis 1 -to_slot 3 -to_fpga B -to_link 60
add_olink -from_chassis 1 -from_slot 1 -from_fpga B -from_link 58 -to_chassis 1 -to_slot 3 -to_fpga B -to_link 59
add_olink -from_chassis 1 -from_slot 1 -from_fpga B -from_link 59 -to_chassis 1 -to_slot 3 -to_fpga B -to_link 57
add_olink -from_chassis 1 -from_slot 1 -from_fpga B -from_link 60 -to_chassis 1 -to_slot 3 -to_fpga B -to_link 58
add_olink -from_chassis 1 -from_slot 2 -from_fpga A -from_link 7 -to_chassis 1 -to_slot 2 -to_fpga B -to_link 43
add_olink -from_chassis 1 -from_slot 2 -from_fpga B -from_link 57 -to_chassis 1 -to_slot 4 -to_fpga B -to_link 59
add_olink -from_chassis 1 -from_slot 2 -from_fpga B -from_link 58 -to_chassis 1 -to_slot 4 -to_fpga B -to_link 60
add_olink -from_chassis 1 -from_slot 2 -from_fpga B -from_link 59 -to_chassis 1 -to_slot 4 -to_fpga B -to_link 57
add_olink -from_chassis 1 -from_slot 2 -from_fpga B -from_link 60 -to_chassis 1 -to_slot 4 -to_fpga B -to_link 58
add_olink -from_chassis 1 -from_slot 3 -from_fpga A -from_link 7 -to_chassis 1 -to_slot 3 -to_fpga B -to_link 43
add_olink -from_chassis 1 -from_slot 4 -from_fpga A -from_link 7 -to_chassis 1 -to_slot 4 -to_fpga B -to_link 43
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 10 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 10
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 11 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 11
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 1 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 1
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 12 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 12
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 13 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 37
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 14 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 38
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 15 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 39
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 16 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 40
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 17 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 41
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 18 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 42
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 19 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 43
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 20 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 44
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 21 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 45
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 2 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 2
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 22 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 46
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 23 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 47
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 24 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 48
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 3 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 3
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 4 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 4
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 5 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 5
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 6 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 6
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 7 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 7
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 8 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 8
add_olink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 9 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 9
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 37 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 13
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 38 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 14
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 39 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 15
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 40 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 16
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 41 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 17
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 42 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 18
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 43 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 19
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 44 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 20
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 45 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 21
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 46 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 22
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 47 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 23
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 48 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 24
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 49 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 49
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 50 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 50
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 51 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 51
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 52 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 52
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 53 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 53
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 54 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 54
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 55 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 55
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 56 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 56
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 57 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 57
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 58 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 58
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 59 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 59
add_olink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 60 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 60
add_olink -from_chassis 1 -from_slot 7 -from_fpga B -from_link 57 -to_chassis 1 -to_slot 9 -to_fpga B -to_link 59
add_olink -from_chassis 1 -from_slot 7 -from_fpga B -from_link 58 -to_chassis 1 -to_slot 9 -to_fpga B -to_link 60
add_olink -from_chassis 1 -from_slot 7 -from_fpga B -from_link 59 -to_chassis 1 -to_slot 9 -to_fpga B -to_link 57
add_olink -from_chassis 1 -from_slot 7 -from_fpga B -from_link 60 -to_chassis 1 -to_slot 9 -to_fpga B -to_link 58

#####################
# FLINK description
#####################
add_flink -from_chassis 1 -from_slot 1 -from_fpga A -from_link 11 -to_chassis 1 -to_slot 2 -to_fpga B -to_link 12
add_flink -from_chassis 1 -from_slot 1 -from_fpga A -from_link 5 -to_chassis 1 -to_slot 2 -to_fpga B -to_link 8
add_flink -from_chassis 1 -from_slot 1 -from_fpga A -from_link 7 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 8
add_flink -from_chassis 1 -from_slot 1 -from_fpga A -from_link 9 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 10
add_flink -from_chassis 1 -from_slot 1 -from_fpga B -from_link 10 -to_chassis 1 -to_slot 2 -to_fpga A -to_link 9
add_flink -from_chassis 1 -from_slot 1 -from_fpga B -from_link 12 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 11
add_flink -from_chassis 1 -from_slot 1 -from_fpga B -from_link 6 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 5
add_flink -from_chassis 1 -from_slot 1 -from_fpga B -from_link 8 -to_chassis 1 -to_slot 2 -to_fpga B -to_link 6
add_flink -from_chassis 1 -from_slot 2 -from_fpga A -from_link 11 -to_chassis 1 -to_slot 3 -to_fpga B -to_link 12
add_flink -from_chassis 1 -from_slot 2 -from_fpga A -from_link 5 -to_chassis 1 -to_slot 3 -to_fpga B -to_link 8
add_flink -from_chassis 1 -from_slot 2 -from_fpga A -from_link 7 -to_chassis 1 -to_slot 3 -to_fpga B -to_link 6
add_flink -from_chassis 1 -from_slot 2 -from_fpga B -from_link 10 -to_chassis 1 -to_slot 3 -to_fpga A -to_link 9
add_flink -from_chassis 1 -from_slot 3 -from_fpga A -from_link 11 -to_chassis 1 -to_slot 4 -to_fpga A -to_link 11
add_flink -from_chassis 1 -from_slot 3 -from_fpga A -from_link 5 -to_chassis 1 -to_slot 4 -to_fpga A -to_link 7
add_flink -from_chassis 1 -from_slot 3 -from_fpga A -from_link 7 -to_chassis 1 -to_slot 4 -to_fpga B -to_link 6
add_flink -from_chassis 1 -from_slot 3 -from_fpga B -from_link 10 -to_chassis 1 -to_slot 4 -to_fpga A -to_link 9
add_flink -from_chassis 1 -from_slot 4 -from_fpga A -from_link 5 -to_chassis 1 -to_slot 5 -to_fpga A -to_link 7
add_flink -from_chassis 1 -from_slot 4 -from_fpga B -from_link 10 -to_chassis 1 -to_slot 5 -to_fpga A -to_link 9
add_flink -from_chassis 1 -from_slot 4 -from_fpga B -from_link 12 -to_chassis 1 -to_slot 5 -to_fpga B -to_link 12
add_flink -from_chassis 1 -from_slot 4 -from_fpga B -from_link 8 -to_chassis 1 -to_slot 5 -to_fpga B -to_link 6
add_flink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 11 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 12
add_flink -from_chassis 1 -from_slot 5 -from_fpga A -from_link 5 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 7
add_flink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 10 -to_chassis 1 -to_slot 6 -to_fpga A -to_link 9
add_flink -from_chassis 1 -from_slot 5 -from_fpga B -from_link 8 -to_chassis 1 -to_slot 6 -to_fpga B -to_link 6

#####################
# MTP24 link description
#####################
add_mtp24_link -from_chassis 1 -from_slot 5 -from_fpga A -to_chassis 1 -to_slot 6 -to_fpga A
add_mtp24_link -from_chassis 1 -from_slot 5 -from_fpga B -to_chassis 1 -to_slot 6 -to_fpga B

#####################
# MTP24 Breakout link description
#####################

#####################
# ICE link description
#####################
add_ice_flink -chassis 1 -ice_name ICE_Cube_3 -ice_link 1 -fabric_slot 3 -fabric_fpga A -fabric_link 1
add_ice_flink -chassis 1 -ice_name ICE_Cube_3 -ice_link 2 -fabric_slot 3 -fabric_fpga A -fabric_link 3
add_ice_flink -chassis 1 -ice_name ICE_Cube_4 -ice_link 1 -fabric_slot 4 -fabric_fpga A -fabric_link 1
add_ice_flink -chassis 1 -ice_name ICE_Cube_4 -ice_link 2 -fabric_slot 4 -fabric_fpga A -fabric_link 3
add_ice_flink -chassis 1 -ice_name ICE_Cube_5 -ice_link 1 -fabric_slot 5 -fabric_fpga A -fabric_link 1
add_ice_flink -chassis 1 -ice_name ICE_Cube_5 -ice_link 2 -fabric_slot 5 -fabric_fpga A -fabric_link 3
add_ice_olink -chassis 1 -ice_name ICE_native_1g_1 -ice_link 1 -fabric_slot 1 -fabric_fpga A -fabric_link 12
add_ice_olink -chassis 1 -ice_name ICE_native_1g_2 -ice_link 1 -fabric_slot 2 -fabric_fpga A -fabric_link 48

#####################
# HPFE description
#####################
add_hpfe -name HOST1
add_hpfe -name HOST2

add_olink -from_chassis 1 -from_slot 2 -from_fpga A -from_link 13 -to_hpfe HOST1 -to_link 1
add_olink -from_chassis 1 -from_slot 2 -from_fpga A -from_link 14 -to_hpfe HOST1 -to_link 2
add_olink -from_chassis 1 -from_slot 3 -from_fpga B -from_link 49 -to_hpfe HOST2 -to_link 1
add_olink -from_chassis 1 -from_slot 3 -from_fpga B -from_link 50 -to_hpfe HOST2 -to_link 2


