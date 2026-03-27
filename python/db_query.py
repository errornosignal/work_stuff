#!/usr/bin/python3
# db_query
# sql/postgres_database_query handler

# runs an SQL query against a remote database
# takes a path for an SQL query file as an argument


class database:
    def __init__(self, name, user, password, host, port):
        self.name = name
        self.user = user
        self.password = password
        self.host = host
        self.port = port

def get_auth(user=None, password=None, prompt=None):
    from getpass import getuser, getpass 
    if user and not password:
        u = getuser()
        auth = u
    if password and not user:
        p = getpass(prompt)    
        auth = p
    if user and password:
        auth = u, p
    return auth

def LDAP_preCheck(db):
    connection = create_connection(db)
    if connection:
        connection.close()
        return True

def send_email(file):
    import subprocess as sp
    sp.call(['emailtome', file])

def yes_no_prompt(question):
    check = str(input(f'{question}(y/n): ')).lower().strip()
    try:
        if check[0] == 'y':
            return True
        elif check[0] == 'n':
            return False
        else:
            print('error: Invalid input')
            return yes_no_prompt(question)
    except Exception as e:
        print('error: Please enter valid input')
        print(e)
        return yes_no_prompt(question)

def create_connection(db):
    from psycopg2 import connect
    connection = None
    try:
        connection = connect(database=db.name, user=db.user, password=db.password, host=db.host, port=db.port)
    except Exception as e:
        print (f'error: create_connection(): {e}')
    else:
        return connection

def get_query_response(db, sql_query):
    import pandas as pd
    import json

    err = (f'error: get_query_response: no connection to {db.host}')
    connection = create_connection(db)
    if connection is not None:
        df = pd.read_sql(sql_query, connection)
        connection.close
        na = df.isna().values.any()
        if na:
            df = df.fillna('n/a')
        response = df.to_json(orient='records')
        response = json.loads(response)
        return response, None
    else:
        print(err)

def run_query(db, query):
    response = get_query_response(db, query)
    if response :
        response , errors = response [0], response [1]
        if errors:
            print(errors)
        return response
    else:
        print('error: run_query: no data')

def main(args):
    import os
    from datetime import datetime
    from tabulate import tabulate
    import pandas as pd
    
    filepath = args.filepath
    
    if not os.path.isfile(filepath):
        raise ValueError(f"Error: {filepath} not found or is not a file")

    with open(filepath, 'r') as file:
        content = file.read()
        print(f'query from [{filepath}]:\n{{\n{content}\n}}\n')

    cli_output = True
    
    user = get_auth(user=True)
    my_domain = "domain.com"
    current_user = (f'{user}@{my_domain}')
    
    email_confirmation = yes_no_prompt(f'Send email with query results to [{current_user}]?')
    
    if email_confirmation:
        cli_output = yes_no_prompt('Still output results here?')
    
    password = get_auth(password=True, prompt='AD Password: ')
    
    my_db = database(name='database_name', user=user, password=password, host='database.domain.com', port=5432) 
    
    if LDAP_preCheck(my_db):
        print('-> running query...')
        time = datetime.now()
        data = run_query(my_db, content)
        df = pd.json_normalize(data)
            
        if cli_output:
            print('\n--- start of results ---')
            print(tabulate(df, showindex=False, headers='keys'))
            print('--- end of results -----\n')
            
        if email_confirmation: 
            outfile = (f'db-query_{time.strftime("%m%d%Y-%H%M%S")}.xlsx')           
            print(f'-> creating [{outfile}]...')
            df.to_excel(outfile, index=False, encoding='utf-8')
            print('-> generating email...')
            send_email(outfile)
            print('-> removing file...')
            os.remove(outfile)
            print('')

if __name__ == '__main__':
    import argparse
    try:
        parser = argparse.ArgumentParser()
        parser.add_argument('filepath', type=str, help='Filepath of the query to be run', default=None)
        args = parser.parse_args()
        main(args)
    except KeyboardInterrupt as e:
        print(f'{str(e)} -KeyboardInterrupt detected.')
        exit(4)
#end
