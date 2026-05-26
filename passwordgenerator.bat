@echo off
chcp 65001 > nul
title Генератор паролей

:main
cls
echo =======================================
echo        ГЕНЕРАТОР НАДЕЖНЫХ ПАРОЛЕЙ
echo =======================================
echo.

:: Задаем набор символов (без спецсимволов, чтобы код не ломался)
set "chars=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

:: Запрос длины пароля
set /p length="Введите длину пароля (рекомендуется от 8 до 16): "

:: Проверка на ввод пустой строки или букв (базовая защита)
if "%length%"=="" set "length=8"
if %length% LEQ 0 set "length=8"

set "password="

:loop
:: Генерируем случайный индекс от 0 до 61 (всего 62 символа в строке)
set /a idx=%random% %% 62

:: Вырезаем случайный символ из строки chars
call set "char=%%chars:~%idx%,1%%"

:: Добавляем символ к паролю
set "password=%password%%char%"

:: Уменьшаем счетчик длины
set /a length-=1

:: Если длина больше 0, повторяем круг
if %length% GTR 0 goto loop

echo.
echo ---------------------------------------
echo Ваш новый пароль: %password%
echo ---------------------------------------
echo.

:retry
echo Хотите сгенерировать еще один? (Y - да, N - выйти)
set /p choice="Ваш выбор: "

if /i "%choice%"=="Y" goto main
if /i "%choice%"=="Н" goto main
exit
