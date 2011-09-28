# Pedestrians and cars

from sage.plot.plot import adjust_figsize_for_aspect_ratio
adjust_figsize_for_aspect_ratio([3,5], 2, 0, 1000, 0, 2)

# Data structure for this intersection for cars is:
#  South-to-north, south-to-east, west-to-east.
# Structure for pedestrians is:
#  South-to-north(east side), north-to-south(east side),
#  east-to-west(north side), west-to-east(north side),
#  north-to-south(west side), south-to-north(west side),
#  west-to-east(south side), east-to-west(south side)
# This is an intersection of two one-way streets.

ped_arrival_distribution = [10, 10, 7, 5, 3, 2, 1, 1, 1, 1]
car_arrival_distribution = [10, 10, 7, 5, 3, 2, 1, 1, 1, 1]

X = GeneralDiscreteDistribution(ped_arrival_distribution) 
Y = GeneralDiscreteDistribution(car_arrival_distribution) 
   
plot_collection = []  

set_random_seed( 0 )

cars = {'stn': [[],0,0], 'ste': [[],0,0], 'wte': [0,0,0]}
peds = {'stn_e': [0,0,0],'nts_e': [0,0,0], 'etw_n': [0,0,0], 'wte_n': [0,0,0], 'nts_w': [0,0,0],'stn_w': [0,0,0], 'wte_s': [0,0,0], 'etw_s': [0,0,0]}
overview = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]

plots = []
matrices = []

iterations = 2

green_ticks = 15
red_ticks = 5
flashing_ticks = 1

car_green_ticks = green_ticks + flashing_ticks
yellow_ticks = red_ticks

def queuer():
    if randint(0,1):
        cars['stn'][0].insert(0,1)
        cars['ste'][0].insert(0,0)
    else:
        cars['stn'][0].insert(0,1)
        cars['ste'][0].insert(0,0)
    cars['wte'][0]+=1
    for key in peds.keys():
        peds[key][0]+=X.get_random_element()

def fill_overview():
    global overview
    overview = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
    for key in peds.keys():
        if key == 'stn_e':
            overview[3][3] += peds[key][0]
            overview[2][3] += peds[key][1]
            #overview[0][3] += peds[key][2] # People in the third spot are finished and not waiting
        elif key == 'nts_e':
            overview[1][3] += peds[key][0]
            overview[2][3] += peds[key][1]
            #overview[4][3] += peds[key][2]            
        elif key == 'etw_n':
            overview[1][3] += peds[key][0]
            overview[1][2] += peds[key][1]
            #overview[1][0] += peds[key][2]            
        elif key == 'wte_n':
            overview[1][1] += peds[key][0]
            overview[1][2] += peds[key][1]
            #overview[1][4] += peds[key][2]            
        elif key == 'nts_w':
            overview[1][1] += peds[key][0]
            overview[2][1] += peds[key][1]
            #overview[4][1] += peds[key][2]            
        elif key == 'stn_w':
            overview[3][1] += peds[key][0]
            overview[2][1] += peds[key][1]
            #overview[0][1] += peds[key][2]            
        elif key == 'wte_s':
            overview[3][1] += peds[key][0]
            overview[3][2] += peds[key][1]
            #overview[3][4] += peds[key][2]            
        else:
            overview[3][3] += peds[key][0]
            overview[3][2] += peds[key][1]
            #overview[3][0] += peds[key][2]     
    for key in cars.keys():
        if key == 'wte':
            overview[2][0] += cars[key][0]
            overview[2][2] += cars[key][1]
            overview[2][4] += cars[key][2] # People in the third spot are finished and not waiting
        elif key == 'stn':
            overview[4][2] += len(cars[key][0])
            overview[2][2] += cars[key][1]
            overview[0][2] += cars[key][2]            
        else:
            overview[4][2] += len(cars[key][0])
            overview[2][2] += cars[key][1]
            overview[2][4] += cars[key][2]                  
    plot_M = matrix_plot( matrix(overview).matrix_from_rows_and_columns([0,1,2,3,4], [0,1,2,3,4]), cmap='Oranges', frame=false ) # , figsize=[7,7]
    #show( plot_M )
    plots.append(plot_M)
    matrix_M = matrix(overview).matrix_from_rows_and_columns([0,1,2,3,4], [0,1,2,3,4])
    matrices.append( matrix_M )
    #print matrix_M
    #print
    
def move_ped_into_street(dirs, mode):
    threshold = 7 # Why should this be seven while that for moving out is only five?
    if mode == 'flashing':
        multiplier = .5
    else:
        multiplier = 1
    for dir in dirs:
        if peds[dir][0] > threshold:
            peds[dir][0] -= threshold*multiplier
            peds[dir][1] += threshold*multiplier
        else:
            peds[dir][1] += peds[dir][0]*multiplier
            peds[dir][0] -= peds[dir][0]*multiplier
                             
def move_ped_out_of_street(dirs):
    threshold = 5
    for dir in dirs:
        if peds[dir][1] > threshold:
            peds[dir][1] -= threshold
            peds[dir][2] += threshold
        else:
            peds[dir][2] += peds[dir][1]
            peds[dir][1] = 0

def move_car_into_street(dirs):
    for dir in dirs:
        if dir == 'wte':
            if cars[dir][1] == 0 and cars[dir][0] != 0:
                cars[dir][1] += 1
                cars[dir][0] -= 1 
        else:
            if cars['stn'][1] == 0 and cars['ste'][1] == 0 and cars[dir][0][len(cars[dir][0])-1] != 0:
                cars[dir][1] += 1
                cars[dir][0].pop()
                
def move_car_out_of_street(dirs):
    for dir in dirs:
        if dir == 'wte':
            if cars[dir][2] == 0 and cars[dir][1] != 0:
                cars[dir][2] += 1
                cars[dir][1] -= 1
        else:
            if cars[dir][2] == 0 and cars[dir][1] != 0:
                cars[dir][2] += 1
                cars[dir][1] -= 1                             
                                 
for i in range(1,iterations):
    queuer()
    # Pedestrian walk
    #print 'Green north and south'                                                         
    for tick in range(1,green_ticks):
        queuer()
        move_ped_into_street( ('stn_e','nts_e','stn_w','nts_w'), 'green' )
        fill_overview()
        move_ped_out_of_street( ('stn_e','nts_e','stn_w','nts_w') )
        fill_overview()     
    #print "Flashing red hand"           
    for tick in range(1,flashing_ticks):
        queuer()                        
        move_ped_into_street( ('stn_e','nts_e','stn_w','nts_w'), 'flashing' )
        fill_overview()
        move_ped_out_of_street( ('stn_e','nts_e','stn_w','nts_w') )                
        fill_overview()
    #print "Red hand"           
    for tick in range(1,red_ticks):
        queuer()                        
        move_ped_out_of_street( ('stn_e','nts_e','stn_w','nts_w') )                
        fill_overview() 
    
    # Car drive
    # East and west
    for tick in range(1,green_ticks):
        queuer()
        move_car_into_street( ('wte',) )
        fill_overview()
        move_car_out_of_street( ('wte',) )     
        fill_overview()
    #print "Yellow"           
    for tick in range(1,yellow_ticks):
        queuer()                        
        move_car_out_of_street( ('wte',) )
        fill_overview()     
        
    # Pedestrian walk                           
    #print 'Green east and west'                                                        
    for tick in range(1,green_ticks):
        queuer()
        move_ped_into_street( ('etw_n','wte_n','wte_s','etw_s'), 'green' )
        fill_overview()
        move_ped_out_of_street( ('etw_n','wte_n','wte_s','etw_s') )     
        fill_overview()
    #print "Flashing red hand"           
    for tick in range(1,flashing_ticks):
        queuer()                        
        move_ped_into_street( ('etw_n','wte_n','wte_s','etw_s'), 'flashing' )
        fill_overview()
        move_ped_out_of_street( ('etw_n','wte_n','wte_s','etw_s') )
        fill_overview()
    #print "Red hand"           
    for tick in range(1,red_ticks):
        queuer()                        
        move_ped_out_of_street( ('etw_n','wte_n','wte_s','etw_s') )
        fill_overview()       

    # Car drive
    # North and south
    for tick in range(1,green_ticks):
        queuer()
        move_car_into_street( ('stn','ste') )
        fill_overview()
        move_car_out_of_street( ('stn','ste') )     
        fill_overview()
    #print "Yellow"           
    for tick in range(1,yellow_ticks):
        queuer()                        
        move_car_out_of_street( ('stn','ste') )
        fill_overview()                            

a = animate(plots)
a.show()

nw = []
ne = []
sw = []
se = []
avg = []
for m in matrices:
    #print m[1,1]
    nw.append( m[0,0] )
    ne.append( m[0,2] )
    sw.append( m[2,0] )
    se.append( m[2,2] )
    avg.append( ( m[0,0] + m[0,2] + m[2,0] + m[2,2] ) / 4 )
p0 = false
p1 = false
p2 = false
p3 = false
pavg = false
fig = 19
thick = .4
p0 = list_plot( nw, plotjoined=True, color=hue(.1), figsize=[fig,1], thickness=thick )
p1 = list_plot( ne, plotjoined=True, color=hue(.4), figsize=[fig,1], thickness=thick )
p2 = list_plot( sw, plotjoined=True, color=hue(.6), figsize=[fig,1], thickness=thick )
p3 = list_plot( se, plotjoined=True, color=hue(.8), figsize=[fig,1], thickness=thick )
print "All corners:"
pavg = list_plot( avg, plotjoined=True, color='black', figsize=[fig,1], thickness=thick )
(p0 + p1 + p2 + p3 + pavg).show()
"""print "NW corner:" 
p0.show()
print "NE corner:"
p1.show()
print "SW corner:"
p2.show()
print "SE corner:"
p3.show()
print "AVG:"
pavg.show()"""
