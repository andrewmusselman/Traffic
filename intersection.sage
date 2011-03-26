# Data structure for this intersection for cars is:
#  South-to-north, south-to-east, west-to-east.
# Structure for pedestrians is:
#  South-to-north(east side), north-to-south(east side), 
#  east-to-west(north side), west-to-east(north side),
#  north-to-south(west side), south-to-north(west side),
#  west-to-east(south side), east-to-west(south side)
# This is an intersection of two one-way streets.
cars = {'stn': [[],0,0], 'ste': [[],0,0], 'wte': [0,0,0]}

peds = {'stn_e': [0,0,0],'nts_e': [0,0,0], 'etw_n': [0,0,0], 'wte_n': [0,0,0], 'nts_w': [0,0,0],'stn_w': [0,0,0], 'wte_s': [0,0,0], 'etw_s': [0,0,0]}

overview = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]

plots = []

iterations = 10

green_ticks = 15

red_ticks = 5

def queuer():
    cars['stn'][0].append(len(cars['stn'][0])+len(cars['ste'][0]))
    cars['ste'][0].append(len(cars['stn'][0])+len(cars['ste'][0]))
    cars['wte'][0]+=1
    for key in peds.keys():
        peds[key][0]+=randint(0,2)
    #print peds

def fill_overview():
    global overview
    overview = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
    for key in peds.keys():
        if key == 'stn_e':
            overview[3][3] += peds[key][0]
            overview[2][3] += peds[key][1]
            overview[0][3] += peds[key][2] # People in the third spot are finished and not waiting
        elif key == 'nts_e':
            overview[1][3] += peds[key][0]
            overview[2][3] += peds[key][1]
            overview[4][3] += peds[key][2]            
        elif key == 'etw_n':
            overview[1][3] += peds[key][0]
            overview[1][2] += peds[key][1]
            overview[1][0] += peds[key][2]            
        elif key == 'wte_n':
            overview[1][1] += peds[key][0]
            overview[1][2] += peds[key][1]
            overview[1][4] += peds[key][2]            
        elif key == 'nts_w':
            overview[1][1] += peds[key][0]
            overview[2][1] += peds[key][1]
            overview[4][1] += peds[key][2]            
        elif key == 'stn_w':
            overview[3][1] += peds[key][0]
            overview[2][1] += peds[key][1]
            overview[0][1] += peds[key][2]            
        elif key == 'wte_s':
            overview[3][1] += peds[key][0]
            overview[3][2] += peds[key][1]
            overview[3][4] += peds[key][2]            
        else:
            overview[3][3] += peds[key][0]
            overview[3][2] += peds[key][1]
            overview[3][0] += peds[key][2]              
    #for car in cars.keys():
    #    print ""
    #print matrix(overview)
    plot_M = matrix_plot(matrix(overview).matrix_from_rows_and_columns([1,2,3], [1,2,3]),cmap='Oranges')
    plot_M.axes(False)
    #plot_M.show()
    #print
    plots.append(plot_M)
    
def move_into_street_stn_nts(dirs):
    for dir in dirs:
        if peds[dir][0]>3:
            peds[dir][0]-=3
            peds[dir][1]+=3         
        elif peds[dir][0]>1:
            peds[dir][0]-=2
            peds[dir][1]+=2 
        elif peds[dir][0]>0:
            peds[dir][0]-=1
            peds[dir][1]+=1 
    #print peds
                             
def move_out_of_street_stn_nts(dirs):
    for dir in dirs:
        if peds[dir][1]>2:
            peds[dir][1]-=3
            peds[dir][2]+=3
        elif peds[dir][1]>1:
            peds[dir][1]-=2
            peds[dir][2]+=2
        elif peds[dir][1]>0:
            peds[dir][1]-=1
            peds[dir][2]+=1            
    #print peds
                                 
for i in range(1,iterations):
    queuer()
    for signal in ('green_s', 'green_w'):
        #print matrix(overview)
        if signal=='green_s':
            #print
            #print 'Green south'                                                         
            for tick in range(1,green_ticks):
                queuer()
                move_into_street_stn_nts(('stn_e','nts_e','stn_w','nts_w'))
                fill_overview()
                move_out_of_street_stn_nts(('stn_e','nts_e','stn_w','nts_w'))
                fill_overview()     
            #print "Red hand"           
            for tick in range(1,red_ticks):
                move_out_of_street_stn_nts(('stn_e','nts_e','stn_w','nts_w'))                
                fill_overview()
        else:
            #print
            #print 'Green west'                                                        
            for tick in range(1,green_ticks):
                queuer()
                move_into_street_stn_nts(('etw_n','wte_n','wte_s','etw_s'))
                fill_overview()
                move_out_of_street_stn_nts(('etw_n','wte_n','wte_s','etw_s'))     
                fill_overview()
            #print "Red hand"           
            for tick in range(1,red_ticks):
                move_out_of_street_stn_nts(('etw_n','wte_n','wte_s','etw_s'))
                fill_overview()
a = animate(plots)
a.show()
