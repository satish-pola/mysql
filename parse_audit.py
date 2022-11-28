import json
import subprocess

## Setup MySQL home and Audit log file variables. 
mysql_log_home='/opt/homebrew/var/mysql'
audit_logfile='audit.log'
audit_log_loc = mysql_log_home+'/'+audit_logfile
email_list = "dbe@intuit.com db-oncall@intuit.com"

## Function to send an violation emails. 
## It sends who violated the rule and how many times.
 
def sendEmail(username, violations, email_list):
  usercall = "echo user " + username + " violated " + str(violations) + " times. |  mail -s MySQL_Violation " + email_list
  print usercall
  subprocess.call(usercall, shell=True)

## Function accepts audit log as input and retuns user violations. 
def parseJson(logfile):
  user_list=[]
  with open('audit.log') as audit_log:
    audit_list = ['NoAudit','Audit']
    for each in audit_log:
      audit_data = json.loads(each)
      if (audit_data['audit_record']['name'] not in audit_list) and (audit_data['audit_record']['status'] == 1044):
        if '@' in (audit_data['audit_record']['user']):
          user_list.append(audit_data['audit_record']['user'].split('@')[0].strip().split('[')[0])
        else:
          user_list.append(audit_data['audit_record']['user'])
    user_list={x:user_list.count(x) for x in user_list}
  return user_list

user_list = parseJson(audit_log_loc)

if __name__ == "__main__":
  for key,val in user_list.items():
    if val > 10:
      sendEmail(key, val, email_list)
