// app/page.tsx
import { fetchExchangeRates } from "@/lib/exchangeRate";

export default async function Page() {
  const data = await fetchExchangeRates("USD", ["EUR", "GBP", "JPY"]);

  return (
    <main className="p-6">
      <h1 className="text-2xl font-bold mb-4">Tassi di cambio (USD)</h1>
      <ul className="space-y-2">
        {Object.entries(data.rates).map(([currency, rate]) => (
          <li key={currency}>
            <strong>{currency}:</strong> {rate}
          </li>
        ))}
      </ul>
      <p className="mt-4 text-sm text-gray-500">
        Ultimo aggiornamento: {data.time_last_update_utc}
      </p>
    </main>
  );
}
