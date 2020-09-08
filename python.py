import json
import re
import requests
def getLogFile(path):
    lines = []
    with open(path, 'r') as f:
        while True:
            line = f.readline()
            if not line:
                break
            lines.append(line)
    return lines

def formatJson(lines):
    for index in range(len(lines)-1,-1,-1):
        if not lines[index].startswith("M"):
            lines[index -1] = lines[index-1].replace('\n', ' ')+lines[index].strip() 
            lines.remove(lines[index]) 
            lines[index -1] = lines[index-1].replace('\n', ' ')+lines[index].strip() 
            lines.remove(lines[index])

        
    for value in lines:
        if value.find("com.apple.xpc.launchd") != -1:
            apple = value.split(" ",6)
            appleJson ={
                "deviceName":apple[3],
                "processId":re.sub(r'\D',"",apple[5]),
                "processName":re.sub(r'[^a-z]',"",apple[5]),
                "description":apple[6],
                "timeWindow":apple[2],
                "numberOfOccurrence": ""
            }
        
        else:
            unapple =value.split(" ",5) 
            unappleJson ={
                "deviceName":apple[3],
                "processId":re.sub(r'\D',"",apple[5]),
                "processName":re.sub(r'[^a-z]',"",apple[5]),
                "description":apple[6],
                "timeWindow":apple[2],
                "numberOfOccurrence": ""
            }
    return json.dumps(appleJson)+json.dumps(unappleJson)
            

def postData(payload):
    r = requests.post('https://foo.com/bar', data=payload)