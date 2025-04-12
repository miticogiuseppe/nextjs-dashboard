// lib/exchangeRate.ts
type ExchangeRateResponse = {
  base_code: string;
  time_last_update_utc: string;
  rates: Record<string, number>;
};

export const fetchExchangeRates = async (
  base: string = "USD",
  symbols: string[] = ["EUR", "GBP", "JPY"]
): Promise<ExchangeRateResponse> => {
  const url = `https://open.er-api.com/v6/latest/${base}`;

  const res = await fetch(url, { cache: "no-store" });

  if (!res.ok) {
    throw new Error(`Errore nella richiesta: ${res.statusText}`);
  }

  const data = await res.json();

  if (!data?.rates) {
    throw new Error("Risposta API non valida");
  }

  // Filtra solo le valute richieste
  const filteredRates: Record<string, number> = {};
  for (const symbol of symbols) {
    if (data.rates[symbol]) {
      filteredRates[symbol] = data.rates[symbol];
    }
  }

  return {
    base_code: data.base_code,
    time_last_update_utc: data.time_last_update_utc,
    rates: filteredRates,
  };
};
