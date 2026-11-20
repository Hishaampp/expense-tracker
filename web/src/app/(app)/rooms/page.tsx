"use client";

import { useMemo } from "react";
import { Browse, Recent, Stats } from "@/components/browse/browse";
import { DayBars } from "@/components/browse/day-bars";
import { CategoryBreakdown } from "@/components/overview/category-breakdown";
import { Card, Quiet } from "@/components/ui/card";
import { PageHeader } from "@/components/ui/page-header";
import { formatCount, formatDate, formatPaise } from "@/lib/format/format";
import type { CategoryLine } from "@/lib/insights/overview";
import { dateOfDay, localDay, roomSummary, type RoomInfo, type RoomSummary } from "@/lib/insights/tables";
import { useLedger, type Ledger } from "@/lib/insights/use-ledger";
import { useQueryState } from "@/lib/url-state";

const RECENT = 8;

function dates(r: RoomInfo): string {
  if (r.startDay === null) return "No dates";
  const from = formatDate(dateOfDay(r.startDay));
  return r.endDay === null ? `From ${from}` : `${from} – ${formatDate(dateOfDay(r.endDay))}`;
}

/** Each trip or Room: its total, its budget, a day-by-day chart, its categories and transactions. */
export default function RoomsPage() {
  const ledger = useLedger();
  const [params, write] = useQueryState();

  const lines = useMemo(() => {
    if (!ledger) return [];
    const today = localDay(ledger.now.getTime());
    return [...ledger.lookup.rooms.values()]
      .map((r) => ({ r, s: roomSummary(r, ledger.txns.filter((t) => t.roomId === r.id), today) }))
      .sort((a, b) => Number(a.r.archived) - Number(b.r.archived) || (b.r.startDay ?? 0) - (a.r.startDay ?? 0) || a.r.name.localeCompare(b.r.name));
  }, [ledger]);

  if (!ledger) return null;
  const chosen = lines.find((l) => l.r.id === params?.get("id")) ?? lines[0];

  return (
    <div className="mx-auto grid max-w-[76rem] gap-8">
      <PageHeader title="Rooms" note="Trips, weddings and events, each kept together." />
      {!chosen ? (
        <Quiet>No Rooms yet. Start one on your phone, in Rooms, to keep a trip or an event together.</Quiet>
      ) : (
        <Browse
          label="Rooms"
          chosen={chosen.r.id}
          onChoose={(id) => write({ id })}
          entries={lines.map(({ r, s }) => ({
            id: r.id,
            name: r.name,
            icon: <span className="grid size-9 place-items-center rounded-xl bg-honey-soft text-[1.125rem]" aria-hidden>{r.emoji ?? "✦"}</span>,
            note: r.archived ? `Archived · ${dates(r)}` : dates(r),
            amount: s.spent,
          }))}
        >
          <Detail room={chosen.r} s={chosen.s} ledger={ledger} />
        </Browse>
      )}
    </div>
  );
}

function Detail({ room, s, ledger }: { room: RoomInfo; s: RoomSummary; ledger: Ledger }) {
  const mine = ledger.items.filter((i) => !i.t.hidden && i.t.roomId === room.id).sort((a, b) => b.t.at - a.t.at);
  const payments = mine.filter((i) => i.t.kind === "expense").length;
  // Every day of a dated Room (to today, for one still going); else the days it was used.
  const today = localDay(ledger.now.getTime());
  const spentOn = new Map(s.byDay.map((d) => [d.day, d.spent]));
  let first = room.startDay;
  let last = room.endDay === null ? today : Math.min(room.endDay, today);
  if (first === null || last < first) {
    const used = s.byDay.map((d) => d.day);
    first = used.length ? Math.min(...used) : null;
    last = used.length ? Math.max(...used) : 0;
  }
  const days = first === null ? [] : Array.from({ length: Math.min(120, last - first + 1) }, (_, i) => ({ date: dateOfDay(first + i), spent: spentOn.get(first + i) ?? 0 }));
  const categories: CategoryLine[] = s.byCategory.map(({ categoryId, spent }) => {
    const c = categoryId ? ledger.lookup.categories.get(categoryId) : undefined;
    return { id: categoryId, name: c?.name ?? "Uncategorised", icon: c?.icon ?? null, spent, share: s.spent > 0 ? spent / s.spent : 0, budget: null, budgetSpent: 0 };
  });
  const over = s.remaining !== null && s.remaining < 0;
  return (
    <>
      <Card id="room" title={`${room.emoji ? `${room.emoji} ` : ""}${room.name}`} note={`${dates(room)}${room.countsTowardBudget ? " · Counts toward the monthly budget" : " · Kept out of the monthly budget"}`} i={3}>
        <Stats
          items={[
            ["Spent", formatPaise(s.spent)],
            s.days !== null ? [s.days === 1 ? "Day" : "Days", formatCount(s.days)] : ["Payments", formatCount(payments)],
            ["Per day", s.perDay !== null ? formatPaise(s.perDay) : "—"],
            [over ? "Over budget" : "Budget left", s.remaining !== null ? formatPaise(Math.abs(s.remaining)) : "No budget"],
          ]}
        />
        {room.budget !== null && room.budget > 0 && (
          <div className="grid gap-1.5">
            <div className="h-2 overflow-hidden rounded-full bg-sunken" role="meter" aria-label="Room budget used" aria-valuemin={0} aria-valuemax={room.budget} aria-valuenow={Math.max(0, Math.min(s.spent, room.budget))}>
              <div className={`grow-x h-full origin-left rounded-full ${over ? "bg-danger" : "bg-honey"}`} style={{ transform: `scaleX(${Math.max(0, Math.min(1, s.progress ?? 0))})` }} />
            </div>
            <p className={`tabular text-[0.8125rem] ${over ? "text-danger" : "text-ink-muted"}`}>
              {formatPaise(s.spent)} of a {formatPaise(room.budget)} budget
            </p>
          </div>
        )}
        {days.length > 0 ? <DayBars days={days} /> : <Quiet>Nothing spent in this Room yet.</Quiet>}
      </Card>
      {categories.length > 0 && (
        <Card id="room-categories" title="Where it went" i={4}>
          <CategoryBreakdown lines={categories} total={s.spent} />
        </Card>
      )}
      <Card id="room-recent" title="Latest" i={5}>
        {mine.length ? <Recent items={mine.slice(0, RECENT)} total={mine.length} href={`/transactions?room=${encodeURIComponent(room.id)}`} /> : <Quiet>Nothing in this Room yet.</Quiet>}
      </Card>
    </>
  );
}
