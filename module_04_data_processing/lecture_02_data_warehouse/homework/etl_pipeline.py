import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
from pathlib import Path
import os

# ============================================
# КОНФИГУРАЦИЯ
# ============================================

# Настройки подключения к PostgreSQL
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'postgres',
    'user': 'admin',
    'password': 'admin123'
}

# Пути к CSV файлам
DATA_PATH = {
    'countries': 'data/countries.csv',
    'cities': 'data/cities.csv',
    'categories': 'data/categories.csv',
    'products': 'data/products.csv',
    'shops': 'data/shops.csv',
    'employees': 'data/employees.csv',
    'customers': 'data/customers.csv',
    'sales': 'data/sales.csv'
}


# ============================================
# ШАГ 1: ПОДКЛЮЧЕНИЕ К БД
# ============================================

def create_db_engine(config):
    """
    Создает подключение к PostgreSQL.
    """
    print("--- Подключение к базе данных PostgreSQL ---")

    db_url = f"postgresql://{config['user']}:{config['password']}@{config['host']}:{config['port']}/{config['database']}"

    try:
        engine = create_engine(db_url, echo=False)

        # Проверяем подключение
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))

        print("✅ Успешное подключение к PostgreSQL\n")
        return engine

    except SQLAlchemyError as e:
        print(f"❌ Ошибка подключения к БД: {e}")
        raise


# ============================================
# ШАГ 2: ПРОВЕРКА СУЩЕСТВОВАНИЯ ТАБЛИЦ
# ============================================

def check_tables_exist(engine):
    """
    Проверяет, существуют ли таблицы в БД.
    Если нет - создает их.
    """
    print("--- Проверка структуры таблиц ---")

    with engine.connect() as conn:
        # Проверяем существование таблиц
        result = conn.execute(text("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """))

        existing_tables = [row[0] for row in result]

        # Список всех таблиц, которые должны быть
        required_tables = ['countries', 'cities', 'categories', 'products',
                           'shops', 'employees', 'customers', 'sales']

        missing_tables = [t for t in required_tables if t not in existing_tables]

        if missing_tables:
            print(f"⚠️ Отсутствуют таблицы: {missing_tables}")
            print("   Пожалуйста, создайте их вручную в pgAdmin или выполните SQL скрипт")
            print("   Или используйте функцию create_all_tables()")
        else:
            print("✅ Все необходимые таблицы существуют\n")

        return existing_tables


# ============================================
# ШАГ 3: ЗАГРУЗКА СПРАВОЧНЫХ ТАБЛИЦ
# ============================================

def load_reference_table(engine, csv_path, table_name, encoding='utf-8'):
    """
    Универсальная функция для загрузки справочных таблиц.
    """
    try:
        print(f"  Загрузка {table_name} из {csv_path}...")

        # Проверяем существование файла
        if not os.path.exists(csv_path):
            raise FileNotFoundError(f"Файл не найден: {csv_path}")

        # Читаем CSV с обработкой разных кодировок и указанием разделителя
        try:
            df = pd.read_csv(csv_path, encoding=encoding, sep=';')
        except UnicodeDecodeError:
            df = pd.read_csv(csv_path, encoding='cp1251', sep=';')

        # Приводим названия колонок к нижнему регистру
        df.columns = [col.lower().strip() for col in df.columns]

        print(f"    Найдено колонок: {list(df.columns)}")
        print(f"    Количество строк: {len(df)}")

        # Загружаем в БД (без схемы, т.к. таблицы в public)
        df.to_sql(
            name=table_name,
            con=engine,
            if_exists='append',  # Добавляем к существующим данным
            index=False,
            method='multi'  # Массовая вставка
        )

        print(f"  ✅ Загружено {len(df)} строк в {table_name}\n")
        return len(df)

    except FileNotFoundError as e:
        print(f"  ❌ {e}\n")
        return 0
    except Exception as e:
        print(f"  ❌ Ошибка при загрузке {table_name}: {e}\n")
        raise


# ============================================
# ШАГ 4: ЗАГРУЗКА ТАБЛИЦЫ ПРОДАЖ С ЧАНКАМИ
# ============================================

def load_sales_table(engine, csv_path, table_name, chunksize=5000):
    """
    Загружает таблицу продаж с использованием чанков.
    """
    total_rows = 0

    try:
        print(f"  Загрузка {table_name} из {csv_path}...")

        if not os.path.exists(csv_path):
            raise FileNotFoundError(f"Файл не найден: {csv_path}")

        try:
            reader = pd.read_csv(csv_path, encoding='utf-8', sep=';', chunksize=chunksize)
        except UnicodeDecodeError:
            reader = pd.read_csv(csv_path, encoding='cp1251', sep=';', chunksize=chunksize)

        # Читаем и загружаем чанками
        for chunk_num, chunk in enumerate(reader, 1):
            # Приводим колонки к нижнему регистру
            chunk.columns = [col.lower().strip() for col in chunk.columns]

            # Загружаем чанк
            chunk.to_sql(
                name=table_name,
                con=engine,
                if_exists='append',
                index=False
            )

            total_rows += len(chunk)
            print(f"    Чанк {chunk_num}: загружено {len(chunk)} строк (всего: {total_rows})")

        print(f"  ✅ Загружено {total_rows} строк в {table_name}\n")
        return total_rows

    except FileNotFoundError as e:
        print(f"  ❌ {e}\n")
        return 0
    except Exception as e:
        print(f"  ❌ Ошибка при загрузке {table_name}: {e}\n")
        raise


# ============================================
# ШАГ 5: ПРОВЕРКА КОЛИЧЕСТВА СТРОК
# ============================================

def verify_row_counts(engine, expected_counts):
    """
    Проверяет количество строк в каждой таблице.
    """
    print("--- Проверка количества строк ---")

    with engine.connect() as conn:
        for table, expected in expected_counts.items():
            try:
                result = conn.execute(text(f"SELECT COUNT(*) FROM {table}"))
                actual = result.scalar()

                if actual == expected:
                    print(f"  ✅ {table}: {actual} строк (соответствует ожиданию)")
                else:
                    print(f"  ⚠️ {table}: ожидалось {expected}, получено {actual} строк")
            except SQLAlchemyError as e:
                print(f"  ❌ Ошибка при проверке {table}: {e}")

        print()


# ============================================
# ШАГ 6: ОЧИСТКА ТАБЛИЦ (ОПЦИОНАЛЬНО)
# ============================================

def truncate_tables(engine, tables):
    """
    Очищает таблицы перед загрузкой (если нужно).
    """
    print("--- Очистка таблиц ---")

    with engine.connect() as conn:
        for table in tables:
            try:
                conn.execute(text(f"TRUNCATE TABLE {table} RESTART IDENTITY CASCADE"))
                print(f"  ✅ Таблица {table} очищена")
            except SQLAlchemyError as e:
                print(f"  ❌ Ошибка при очистке {table}: {e}")

        conn.commit()
        print()


# ============================================
# ОСНОВНАЯ ФУНКЦИЯ ETL
# ============================================

def run_etl_pipeline():
    """
    Основная функция ETL-процесса.
    """
    print("=" * 70)
    print("ЗАПУСК ETL-ПРОЦЕССА ДЛЯ ЗАГРУЗКИ ДАННЫХ")
    print("=" * 70)
    print()

    try:
        # 1. Подключение к БД
        engine = create_db_engine(DB_CONFIG)

        # 2. Проверка таблиц
        existing_tables = check_tables_exist(engine)

        # 3. Спрашиваем пользователя, нужно ли очистить таблицы
        clean = input("Очистить таблицы перед загрузкой? (y/n): ").lower()
        if clean == 'y':
            tables_to_clean = ['countries', 'cities', 'categories', 'products',
                               'shops', 'employees', 'customers', 'sales']
            truncate_tables(engine, tables_to_clean)

        print("--- Загрузка данных ---\n")

        # 4. Загрузка справочных таблиц (согласно порядку, учитывая внешние ключи)
        results = {}

        # Страны
        results['countries'] = load_reference_table(
            engine, DATA_PATH['countries'], 'countries'
        )

        # Города (зависят от стран)
        results['cities'] = load_reference_table(
            engine, DATA_PATH['cities'], 'cities'
        )

        # Категории
        results['categories'] = load_reference_table(
            engine, DATA_PATH['categories'], 'categories'
        )

        # Продукты (зависят от категорий)
        results['products'] = load_reference_table(
            engine, DATA_PATH['products'], 'products'
        )

        # Магазины (зависят от городов)
        results['shops'] = load_reference_table(
            engine, DATA_PATH['shops'], 'shops'
        )

        # Сотрудники (зависят от магазинов)
        results['employees'] = load_reference_table(
            engine, DATA_PATH['employees'], 'employees'
        )

        # Клиенты (зависят от городов)
        results['customers'] = load_reference_table(
            engine, DATA_PATH['customers'], 'customers'
        )

        # 5. Загрузка продаж с чанками
        results['sales'] = load_sales_table(
            engine, DATA_PATH['sales'], 'sales', chunksize=5000
        )

        # 6. Проверка количества строк
        # ВАЖНО: Замените цифры на реальное количество строк в ваших CSV файлах!
        expected_counts = {
            'countries': 5,  # Посчитайте строки в countries.csv (минус заголовок)
            'cities': 21,  # Посчитайте строки в cities.csv (минус заголовок)
            'categories': 15,
            'products': 507,
            'shops': 72,
            'employees': 320,
            'customers': 100000,
            'sales': 2000006  # Посчитайте строки в sales.csv (минус заголовок)
        }
        verify_row_counts(engine, expected_counts)

        # 7. Итоговый отчет
        print("=" * 70)
        print("📊 ИТОГОВЫЙ ОТЧЕТ О ЗАГРУЗКЕ")
        print("=" * 70)
        for table, count in results.items():
            print(f"  {table}: {count} строк загружено")
        print("=" * 70)
        print("🎉 ETL-ПРОЦЕСС УСПЕШНО ЗАВЕРШЕН!")
        print("=" * 70)

    except FileNotFoundError as e:
        print(f"\n❌ Ошибка: {e}")
        print("   Проверьте, что CSV файлы находятся в папке 'data'")
    except SQLAlchemyError as e:
        print(f"\n❌ Ошибка базы данных: {e}")
    except KeyboardInterrupt:
        print("\n⚠️ Процесс прерван пользователем")
    except Exception as e:
        print(f"\n❌ Произошла непредвиденная ошибка: {e}")
        import traceback
        traceback.print_exc()



if __name__ == "__main__":
    run_etl_pipeline()