#!/bin/bash

calculate_network_range() {
    IFS='.' read -r -a gateway_octets <<< "$1"
    if [[ ${gateway_octets[0]} -eq 10 ]]; then
        network_range="${gateway_octets[0]}.0.0.0/8"
    elif [[ ${gateway_octets[0]} -eq 172 && ${gateway_octets[1]} -ge 16 && ${gateway_octets[1]} -le 31 ]]; then
        network_range="${gateway_octets[0]}.${gateway_octets[1]}.0.0/16"
    elif [[ ${gateway_octets[0]} -eq 192 && ${gateway_octets[1]} -eq 168 ]]; then
        network_range="${gateway_octets[0]}.${gateway_octets[1]}.${gateway_octets[2]}.0/24"
    else
        echo "Не удалось определить класс IP-адреса"
        exit 1
    fi
}
print_color() {
    color="$1"
    text="$2"
    echo -e "${color}${text}\e[0m"
}
print_line() {
    echo "────────────────────────────────────────────"
}

camera_ports=("554" "80")

check_host() {
    local host="$1"
    local nmap_output
    nmap_output=$(nmap -sV "$host")
    if echo "$nmap_output" | grep -q "554/tcp"; then
        print_color "\e[1;35m" "Хост $host является камерой!"
    fi
}

print_color "\e[1;32m" "Добро пожаловать в сканер Камер! от BlackGonza"
print_line

read -p "$(print_color '\e[1m\e[33m' 'Введите IP-адрес шлюза: ')" gateway

if ! [[ $gateway =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    print_color "\e[1;31m" "Ошибка: некорректный IP-адрес шлюза"
    exit 1
fi

calculate_network_range "$gateway"

nmap_command="nmap -sn $network_range | grep 'report for' | cut -d ' ' -f 5"
print_color "\e[1;36m" "Выполняется обнаружение хостов в сети с использованием команды: $nmap_command"
host_list=$(eval "$nmap_command")

print_color "\e[1;32m" "Обнаружены следующие хосты:"
print_line
for host in $host_list; do
    print_color "\e[1;34m" "Хост: $host"
    check_host "$host"
done
print_line

print_color "\e[1;36m" "Спасибо за использование сканера камер от BlackGonza!"
