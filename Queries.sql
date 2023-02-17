USE RiskSimulation;

# Analisando comportamento baseado em quantidade de cartões utilizados no mesmo dia
# pelo mesmo usuário
SELECT user_id,
	DATE_FORMAT(transaction_date, '%Y-%m-%d') as dia, 
    COUNT(DISTINCT card_number) as qtde_cartões,
    SUM(has_cbk) as tem_cbk,
	CASE
        WHEN SUM(has_cbk) > 0 THEN 'Fraude já identificada'
        ELSE 'Suspeita de fraude, utilizou mais de 2 cartões no mesmo dia'
    END AS situacao_atual
FROM transactions
GROUP BY user_id, dia
HAVING qtde_cartões > 2
ORDER BY user_id;

# Analisando comportamento baseado em quantidade de transaçoes
# por hora. No caso, acima de 1 trans. por hora
SELECT user_id, card_number, 
	DATE_FORMAT(transaction_date, '%Y-%m-%d %H') as hora, 
    COUNT(transaction_date) as transacoes,
    SUM(has_cbk) as tem_cbk,
	CASE
        WHEN COUNT(transaction_date) = SUM(has_cbk) THEN 'Fraude já identificada'
        ELSE 'Suspeita de fraude, mais de uma transação em curto periodo de tempo'
    END AS situacao_atual
FROM transactions
GROUP BY user_id, card_number, hora
HAVING count(transaction_date) > 1
ORDER BY user_id;


# Mesmo cartão de crédito associado a diferentes usuários:
SELECT A.card_number, B.user_id, A.has_cbk
FROM transactions as A, transactions as B
WHERE A.card_number = B.card_number
	  AND A.user_id <> B.user_id
GROUP BY A.card_number, B.user_id, A.has_cbk;

# Mesmo cartão de crédito associado a diferentes usuários que não tiveram chargeback por fraude:
SELECT A.card_number, B.user_id, A.has_cbk
FROM transactions as A, transactions as B
WHERE A.card_number = B.card_number
	  AND A.user_id <> B.user_id AND NOT A.has_cbk
GROUP BY A.card_number, B.user_id, A.has_cbk;

# Quantidade de cartões que se encontram associados a diferentes usuários:
SELECT COUNT(DISTINCT R.card_number)
FROM
	(SELECT A.card_number, B.user_id, A.has_cbk
	FROM transactions as A, transactions as B
	WHERE A.card_number = B.card_number
	AND A.user_id <> B.user_id
	GROUP BY A.card_number, B.user_id, A.has_cbk) AS R;


