from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import traceback
options = Options()
#options.add_argument('--headless=new')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--disable-gpu')

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

try:
    driver.get("")


    driver.find_element(By.ID, "user_id").send_keys("12345")
    driver.find_element(By.ID, "destination_name").send_keys("Mall")
    driver.find_element(By.ID, "arrival_time").send_keys("12:03")
    driver.find_element(By.ID, "arrival_datetime").send_keys("2025-05-31T23:59")
    driver.find_element(By.ID, "is_one_time_yes").click()
    driver.find_element(By.ID, "origin_address").send_keys("")
    driver.find_element(By.ID, "destination_address").send_keys("1400 Willowbrook Blvd, Wayne, NJ 07470")

    driver.execute_script("document.querySelector('form').submit();")

    
    WebDriverWait(driver, 20).until(EC.alert_is_present())
    alert = driver.switch_to.alert
    print("Alert text:", alert.text)
    alert.accept()

except Exception as e:
    print("Exception Occurred:", e)
    traceback.print_exc()
finally:
    driver.quit()

#Form does not return submit alert, and does not post to dynamodb, might be AWS anti-bot security?