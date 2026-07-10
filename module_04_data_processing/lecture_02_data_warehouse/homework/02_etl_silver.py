import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
import numpy as np
from datetime import datetime

# ============================================
# КОНФИГУРАЦИЯ
# ============================================

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'postgres',
    'user': 'admin',
    'password': 'admin123'
}


# ============================================
# ПОДКЛЮЧЕНИЕ К БД
# ============================================

def create_db_engine(config):
    """Создает подключение к PostgreSQL."""
    db_url = f"postgresql://{config['user']}:{config['password']}@{config['host']}:{config['port']}/{config['database']}"
    try:
        engine = create_engine(db_url, echo=False)
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        print("✅ Успешное подключение к PostgreSQL")
        return engine
    except SQLAlchemyError as e:
        print(f"❌ Ошибка подключения: {e}")
        raise


# ============================================
# ФУНКЦИЯ 1: ВАЛИДАЦИЯ ДАТ
# ============================================

def validate_and_fix_date(date_str):
    """
    Пытается исправить "грязные" даты.

    Если дата корректная → возвращает дату.
    Если дата некорректная → возвращает 1900-01-01.
    """
    if pd.isna(date_str) or date_str == '' or date_str == 'NULL':
        return pd.NaT

    # Убираем лишние пробелы
    date_str = str(date_str).strip()

    # Список возможных форматов
    formats = [
        '%Y-%m-%d',  # 2023-05-19
        '%d/%m/%Y',  # 19/05/2023
        '%m/%d/%Y',  # 05/19/2023
        '%Y/%m/%d',  # 2023/05/19
        '%d-%m-%Y',  # 19-05-2023
        '%m-%d-%Y',  # 05-19-2023
        '%Y%m%d',  # 20230519
        '%d.%m.%Y',  # 19.05.2023
        '%b %d, %Y',  # May 19, 2023
        '%d %b %Y',  # 19 May 2023
        '%B %d, %Y',  # May 19, 2023
        '%d %B %Y'  # 19 May 2023
    ]

    for fmt in formats:
        try:
            date_obj = datetime.strptime(date_str, fmt)
            # Проверка на реалистичность (год между 1900 и 2100)
            if 1900 <= date_obj.year <= 2100:
                return date_obj.date()
        except (ValueError, TypeError):
            continue

    # Если ничего не подошло → технический дефолт
    return datetime.strptime('1900-01-01', '%Y-%m-%d').date()


# ============================================
# ФУНКЦИЯ 2: ЗАГРУЗКА СПРАВОЧНИКОВ
# ============================================

def load_silver_reference(engine, bronze_table, silver_table, columns=None):
    """Загружает справочные таблицы из Bronze в Silver."""
    try:
        print(f"  Загрузка {silver_table} из {bronze_table}...")

        # Читаем из Bronze
        df = pd.read_sql_table(bronze_table, con=engine, schema='public')
        print(f"    Прочитано {len(df)} строк из {bronze_table}")

        # Загружаем в Silver
        df.to_sql(
            name=silver_table,
            con=engine,
            schema='silver',
            if_exists='append',
            index=False,
            method='multi'
        )

        print(f"  ✅ Загружено {len(df)} строк в {silver_table}\n")
        return len(df)

    except Exception as e:
        print(f"  ❌ Ошибка при загрузке {silver_table}: {e}\n")
        return 0


# ============================================
# ФУНКЦИЯ 3: ЗАГРУЗКА EMPLOYEES (С ОЧИСТКОЙ ДАТ)
# ============================================

def load_silver_employees(engine):
    """Загружает сотрудников с очисткой дат."""
    try:
        print("  Загрузка silver_employees из employees...")

        # Читаем из Bronze
        df = pd.read_sql_table('employees', con=engine, schema='public')
        print(f"    Прочитано {len(df)} строк из employees")

        # Очищаем даты рождения
        print("    Очистка birth_date...")
        df['birth_date'] = df['birth_date'].apply(validate_and_fix_date)

        # Очищаем даты найма
        print("    Очистка hire_date...")
        df['hire_date'] = df['hire_date'].apply(validate_and_fix_date)

        # Удаляем строки, где обе даты невалидны
        initial_count = len(df)
        df = df.dropna(subset=['birth_date', 'hire_date'], how='all')
        print(f"    Удалено {initial_count - len(df)} строк с некорректными датами")

        # Загружаем в Silver
        df.to_sql(
            name='silver_employees',
            con=engine,
            schema='silver',
            if_exists='append',
            index=False,
            method='multi'
        )

        print(f"  ✅ Загружено {len(df)} строк в silver_employees\n")
        return len(df)

    except Exception as e:
        print(f"  ❌ Ошибка при загрузке silver_employees: {e}\n")
        return 0


# ============================================
# ФУНКЦИЯ 4: ЗАГРУЗКА PRODUCTS (С ПРЕОБРАЗОВАНИЕМ BOOLEAN)
# ============================================

def load_silver_products(engine):
    """Загружает продукты с преобразованием boolean."""
    try:
        print("  Загрузка silver_products из products...")

        # Читаем из Bronze
        df = pd.read_sql_table('products', con=engine, schema='public')
        print(f"    Прочитано {len(df)} строк из products")

        # Преобразуем строки в boolean
        def str_to_bool(val):
            if pd.isna(val):
                return False
            if isinstance(val, bool):
                return val
            if isinstance(val, str):
                val = val.lower().strip()
                return val in ('true', '1', 'yes', 't', 'y')
            return bool(val)

        df['resistant'] = df['resistant'].apply(str_to_bool)
        df['is_allergic'] = df['is_allergic'].apply(str_to_bool)

        # Приводим цены к numeric
        df['price'] = pd.to_numeric(df['price'], errors='coerce').fillna(0)

        # Загружаем в Silver
        df.to_sql(
            name='silver_products',
            con=engine,
            schema='silver',
            if_exists='append',
            index=False,
            method='multi'
        )

        print(f"  ✅ Загружено {len(df)} строк в silver_products\n")
        return len(df)

    except Exception as e:
        print(f"  ❌ Ошибка при загрузке silver_products: {e}\n")
        return 0


# ============================================
# ФУНКЦИЯ 5: ЗАГРУЗКА SALES (С ОЧИСТКОЙ ТАЙМСТАМПОВ)
# ============================================

def load_silver_sales(engine):
    """Загружает продажи с очисткой временных меток."""
    try:
        print("  Загрузка silver_sales из sales...")

        # Читаем из Bronze (чанками, т.к. данных много)
        chunksize = 10000
        total_rows = 0
        first_chunk = True

        # Создаем таблицу (если не существует)
        # Она уже создана через DDL, но на всякий случай

        for chunk in pd.read_sql_table('sales', con=engine, schema='public', chunksize=chunksize):
            print(f"    Обработка чанка...")

            # Очищаем timestamp
            def fix_timestamp(ts):
                if pd.isna(ts) or ts == '' or ts == 'NULL':
                    return pd.NaT
                try:
                    # Если это строка, пробуем парсить
                    if isinstance(ts, str):
                        # Если есть время, но нет даты
                        if ' ' not in ts:
                            ts = ts + ' 00:00:00'
                        return pd.to_datetime(ts)
                    return pd.to_datetime(ts)
                except:
                    return pd.NaT

            chunk['sales_timestamp'] = chunk['sales_timestamp'].apply(fix_timestamp)

            # Удаляем строки, где дата невалидна
            chunk = chunk.dropna(subset=['sales_timestamp'])

            # Приводим цены и скидки к numeric
            chunk['total_price'] = pd.to_numeric(chunk['total_price'], errors='coerce').fillna(0)
            chunk['discount'] = pd.to_numeric(chunk['discount'], errors='coerce').fillna(0)

            # Добавляем shop_id и city_id (пока NULL, заполним позже SQL)
            chunk['shop_id'] = None
            chunk['city_id'] = None

            # Загружаем в Silver
            chunk.to_sql(
                name='silver_sales',
                con=engine,
                schema='silver',
                if_exists='append' if not first_chunk else 'append',
                index=False,
                method='multi'
            )

            total_rows += len(chunk)
            first_chunk = False
            print(f"      Загружено {len(chunk)} строк (всего: {total_rows})")

        print(f"  ✅ Загружено {total_rows} строк в silver_sales\n")
        return total_rows

    except Exception as e:
        print(f"  ❌ Ошибка при загрузке silver_sales: {e}\n")
        return 0


# ============================================
# ОСНОВНАЯ ФУНКЦИЯ
# ============================================

def run_etl_silver():
    """Основная функция ETL для Silver слоя."""
    print("=" * 70)
    print("ЗАПУСК ETL ДЛЯ SILVER СЛОЯ")
    print("=" * 70)
    print()

    try:
        # Подключаемся к БД
        engine = create_db_engine(DB_CONFIG)

        print("--- Загрузка данных в Silver ---\n")

        # 1. Загружаем справочники
        load_silver_reference(engine, 'countries', 'silver_countries')
        load_silver_reference(engine, 'cities', 'silver_cities')
        load_silver_reference(engine, 'categories', 'silver_categories')

        # 2. Загружаем продукты (с преобразованием boolean)
        load_silver_products(engine)

        # 3. Загружаем магазины
        load_silver_reference(engine, 'shops', 'silver_shops')

        # 4. Загружаем сотрудников (с очисткой дат)
        load_silver_employees(engine)

        # 5. Загружаем клиентов
        load_silver_reference(engine, 'customers', 'silver_customers')

        # 6. Загружаем продажи (с очисткой timestamp)
        load_silver_sales(engine)

        print("=" * 70)
        print("🎉 ETL ДЛЯ SILVER СЛОЯ УСПЕШНО ЗАВЕРШЕН!")
        print("=" * 70)
        print()
        print("📌 ДАЛЬНЕЙШИЕ ШАГИ:")
        print("  1. Запустите 03_data_hygiene.sql для очистки данных")
        print("  2. Запустите 04_constraints.sql для установки ограничений")

    except Exception as e:
        print(f"\n❌ Произошла ошибка: {e}")
        import traceback
        traceback.print_exc()


# ============================================
# ЗАПУСК
# ============================================

if __name__ == "__main__":
    run_etl_silver()