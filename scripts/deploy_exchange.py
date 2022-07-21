from scripts.helpful_scripts import deploy_mock
from brownie import network


def main():
    if network.show_active() == "development":
        mock = deploy_mock()
        print(f"Contract: {mock}")
