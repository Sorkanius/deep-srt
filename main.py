import argparse
import os
import json
import time

from azure.storage.fileshare import ShareDirectoryClient, ShareFileClient


def arg_parser():
    parser = argparse.ArgumentParser(description='Launch test in Azure between regions and analyze the results.')

    parser.add_argument('-n', '--name', required=True,
                        help='Unique name of the test to conduct')
    parser.add_argument('-t', '--transmitter_context', default='olympiaCluster',
                        help='Cluster for the transmitter')
    parser.add_argument('-r', '--receiver_context', default='olympiaFR',
                        help='Cluster for the receiver')
    parser.add_argument('-l', '--latency', default=120,
                        help='Latency of the SRT transmission')

    return parser.parse_args()


def download_files(conn_str, share_name, file_path, save_path, prefix):

    extensions = ['vSRT.pcapng', 'logs.csv']

    for ext in extensions:

        file = f'{prefix}-{ext}'
        file_client = ShareFileClient.from_connection_string(conn_str=conn_str,
                                                             share_name=share_name,
                                                             file_path=f'{file_path}/{file}')

        with open(save_path + file, 'wb') as file_handle:
            data = file_client.download_file()
            data.readinto(file_handle)


def list_azure_dir(conn_str, share_name, directory_path='./'):
    parent_dir = ShareDirectoryClient.from_connection_string(conn_str=conn_str,
                                                             share_name=share_name,
                                                             directory_path=directory_path)
    return list(parent_dir.list_directories_and_files())


if __name__ == '__main__':
    args = arg_parser()

    with open('secrets.json') as json_file:
        secrets = json.load(json_file)

    print(args)

    klaunch = f'./klaunch.sh {args.name} {args.transmitter_context} {args.receiver_context} {args.latency}'

    print(f'Command launched: {klaunch}')
    os.system(klaunch)

    print('Waiting for tshark to finish capture...')
    time.sleep(60)
    print('... tshark finished capture.')

    os.mkdir(f'data/{args.name}/')

    print('Getting sender data...')
    items = list_azure_dir(conn_str=secrets[args.transmitter_context]['connectionString'],
                           share_name=secrets[args.transmitter_context]['shareName'])
    for item in items:
        if args.name in item['name']:
            download_files(conn_str=secrets[args.transmitter_context]['connectionString'],
                           share_name=secrets[args.transmitter_context]['shareName'],
                           file_path=item["name"],
                           save_path=f'data/{args.name}/',
                           prefix='snd')
            break

    print('Getting receiver data...')
    items = list_azure_dir(conn_str=secrets[args.receiver_context]['connectionString'],
                           share_name=secrets[args.receiver_context]['shareName'])
    for item in items:
        if args.name in item['name']:
            download_files(conn_str=secrets[args.receiver_context]['connectionString'],
                           share_name=secrets[args.receiver_context]['shareName'],
                           file_path=item["name"],
                           save_path=f'data/{args.name}/',
                           prefix='rcv')
            break
