clear all;
clc;
tamanho_cromossomo=45;
tamanho_popu=60;
elite=4; %numero de individuos da elite que ir„o passar
geracoes=59;

pop_i=gerar_pop(tamanho_popu,tamanho_cromossomo);
[pop_rankeado, elites, notas]=ranked(pop_i,tamanho_popu, tamanho_cromossomo, elite, 1);

gera=1
rank1=pop_rankeado;

for i=1:geracoes
    gera=i+1
    pop_i=gerar_nova_pop(tamanho_popu, tamanho_cromossomo, elites, pop_rankeado,notas, pop_i);
    [pop_rankeado, elites, notas]=ranked(pop_i, tamanho_popu, tamanho_cromossomo, elite, gera);
end

function novo_cromo=criar_cromossomo()
    %Criar erro de -30 a 30
    for i=1:15
        tempo1(i)=(60*rand)-30;
    end
    tempo1=sort(tempo1);
    %Criar var_erro de -0.3 a 0.3
    for i=1:9
        tempo2(i)=(0.6*rand)-0.3;
        tempo2=sort(tempo2);
    end
    tempo2=sort(tempo2);
    %0.1's entre 10^-1 e 10^-3 e os maiores entre 1 e 10
    for i=1:3
        tempo3(i)=0.099*rand()+0.001;
        tempo4(i)=9*rand()+1;
    end
    tempo3=sort(tempo3);
    tempo4=sort(tempo4);
    finalesco=[tempo3(1) tempo4(1) tempo3(2) tempo4(2) tempo3(3) tempo4(3)];
    regra=[2 3 3 2 1 1 2 1 2 1 1 2 2 3 2];
    %finalesco=[0.01 3 0.01 3.5 0.1 5];
    novo_cromo=[tempo1 tempo2 regra finalesco];
end

function pop=gerar_pop(tamanho_pop, tamanho_individuo)
    for i=1:tamanho_pop
        pop(i,:)=criar_cromossomo();
    end
end

function [pop_rankeado, elites, notas]=ranked(populacao,tamanho_pop, tamanho_individuo, qntd_elite, gera_atual)
    for i=1:tamanho_pop
        itera=[gera_atual i]
        %Para cada individuo gera um fis, simula, da a nota
        AGfiss(populacao(i,:)); 
        sim('Simulacao_Exemplo_04_Fuzzy_v2');
        teste_divergencia=sort(Niveis(:,4));
        tamanho=length(teste_divergencia);
        if teste_divergencia(tamanho)>=22
            notas(i)=100;
        else
            notas(i)=goodhart(Sinal_Controle_U(:,2),15,Niveis(:,4));
        end
    end
    temp=[populacao notas']; %concatena a populaÁ„o c a nota de cada individuo
    temp_sorted=sortrows(temp,tamanho_individuo+1,{'ascend'}); %Rankeia de maneira crescente (menor nota em cima pois È melhor)
    elites=temp_sorted(1:qntd_elite,1:tamanho_individuo); %Separa os da elite
    pop_rankeado=temp_sorted; %vetor populaÁ„o+nota rankeado
    notas=pop_rankeado(:,tamanho_individuo+1); %vetor coluna sÛ de notas
end

function posicao=sorteio(notas, tamanho_pop)
    nova_nota=1./notas;
    soma_notas=0;
    for i=1:tamanho_pop
        soma_notas=notas(i)+soma_notas;
    end    
    sorteado=soma_notas*rand;    
    pos=0;
    i=0;
    while pos<sorteado
        i=i+1;
        pos=notas(i)+pos;
        posicao=i;
    end
end


function filho=gerar_novo_individuo(pai1, pai2, pai3, tamanho_individuo)
    filho=[pai1(1,1:15) pai2(1,16:24) pai3(1,25:45)];
    %filho=[pai1(1,1:3) pai2(1,4:6) pai3(1,7:9) pai1(1,10:12) pai2(1,13:15) pai3(1,16:18) pai1(1,19:21) pai2(1,22:24) pai3(1,25:39) pai1(1,40:41) pai2(1,42:43) pai3(1,44:45)];
    chance_wolwerine=rand;
    if chance_wolwerine<=0.05
        pos_mut=ceil(39*rand); %arredonda pra cima pra nunca ser zero, sÛ pos final do cromossomo
        if (pos_mut>=1)&&(pos_mut<=15)
            filho(pos_mut)=(60*rand)-30;
        elseif (pos_mut>=16)&&(pos_mut<=24)
            filho(pos_mut)=(0.6*rand)-0.3;
        else
            filho(pos_mut)=ceil(3*rand);
        end
    end
    tempo1=sort(filho(1:15));
    tempo2=sort(filho(16:24));
    filho=[tempo1 tempo2 filho(25:45)];
end


function nova_populacao=gerar_nova_pop(tamanho_pop, tamanho_individuo, elites, ordenado, notas, populacao_pai)
    nova_populacao=[];
    for i=1:tamanho_pop-6
        pos1=sorteio(notas,tamanho_pop);
        pos2=sorteio(notas,tamanho_pop);
        pos3=sorteio(notas,tamanho_pop);
        nova_populacao(i,:)=gerar_novo_individuo(populacao_pai(pos1,:),populacao_pai(pos2,:),populacao_pai(pos3,:),tamanho_individuo);
        nova_populacao(i+1,:)=gerar_novo_individuo(populacao_pai(pos3,:),populacao_pai(pos1,:),populacao_pai(pos2,:),tamanho_individuo);
        nova_populacao(i+2,:)=gerar_novo_individuo(populacao_pai(pos2,:),populacao_pai(pos3,:),populacao_pai(pos1,:),tamanho_individuo);
        i=i+2;
    end
    if length(nova_populacao)>=tamanho_pop-4
        nova_populacao=nova_populacao(1:tamanho_pop-4,:);
    end
    nova_populacao=[nova_populacao; elites];
end

%FunÁ„o Jaci
function AGfiss(cromo)

%cromossomo de teste:
%cromo = [-30 -24.9 -19.2 -15.4 -11.2 -5 -2.2 0 2.02 5 10.6 14.8 18 22.8 30 -0.3 -0.23 -0.122 -0.05 0 0.044 0.104 0.144 0.3 1 2 1 2 3 1 1 2 3 1 2 1 3 2 3 0.01 3 0.01 3.5 0.1 5]
%saidaf = 0;

%

%b = sugfis('tipper');  %cria um novo fis
b = sugfis;
%b.type = 'sugeno';      %mudo de mamdami para sugeno

b = addvar(b,'input','erro',[cromo(1) cromo(15)]); % crio a entrada do erro
% A seguir s√£o especificados os paramentros das fun√ß√µes do erro
b = addmf(b,'input',1,'NG','trimf',[cromo(1) cromo(2) cromo(4)]);  
b = addmf(b,'input',1,'NP','trimf',[cromo(3) cromo(5) cromo(7)]);
b = addmf(b,'input',1,'EZ','trimf',[cromo(6) cromo(8) cromo(10)]);
b = addmf(b,'input',1,'PP','trimf',[cromo(9) cromo(11) cromo(13)]);
b = addmf(b,'input',1,'PG','trimf',[cromo(12) cromo(14) cromo(15)]);

b = addvar(b,'input','var_erro',[cromo(16) cromo(24)]); % crio a entrada da varia√ß√£o do erro
% A seguir s√£o especificados os paramentros das fun√ß√µes da varia√ß√£o do erro
b = addmf(b,'input',2,'VP','trimf',[cromo(16) cromo(17) cromo(19)]);
b = addmf(b,'input',2,'VZ','trimf',[cromo(18) cromo(20) cromo(22)]);
b = addmf(b,'input',2,'VG','trimf',[cromo(21) cromo(23) cromo(24)]);

b = addvar(b,'output','saidaFuzzy',[0 1]);  % crio a saida do controle
b = addmf(b,'output',1,'GUP','linear',[cromo(40) cromo(41) 0]);
b = addmf(b,'output',1,'GUM','linear',[cromo(42) cromo(43) 0]);
b = addmf(b,'output',1,'GUG','linear',[cromo(44) cromo(45) 0]);

%especifico as regras;
%primeira coluna √© referente as fun√ß√µes do erro
%segunda coluna referente as fun√ß√µes da varia√ß√£o do erro
%a terceira coluna √© referente a saida do controle
%a quarta e quinta n√£o varia, sempre √© 1 e 1
ruleList = [1 1 cromo(25) 1 1;
            1 2 cromo(26) 1 1;
            1 3 cromo(27) 1 1;
            2 1 cromo(28) 1 1;
            2 2 cromo(29) 1 1;
            2 3 cromo(30) 1 1;
            3 1 cromo(31) 1 1
            3 2 cromo(32) 1 1;
            3 3 cromo(33) 1 1;
            4 1 cromo(34) 1 1;
            4 2 cromo(35) 1 1;
            4 3 cromo(36) 1 1;
            5 1 cromo(37) 1 1;
            5 2 cromo(38) 1 1;
            5 3 cromo(39) 1 1];
                
            
b = addrule(b,ruleList);

%sug_fis = mam2sug(b)  %transforma de mamdani para sugeno

writefis(b,'my_file');   %crio o aquivo .fis
end

%FunÁ„o Rafael
function IG = goodhart(u,r,y)
    alfa1=0.2;
    alfa2=0.3;
    alfa3=0.5;
    
    %R=setpoint
    %U=sinal de controle Sinal_Controle_U(:,2)
    %Y=saÌda - Niveis(:,4)

    L1=length(u);
    L2=length(y);

    E1 = sum(u)/L1;
    E2 = sum((u-E1))^2/L1;
    E3 = sum((r-y))^2/L2;

    IG = (alfa1*E1 + alfa2*E2 + alfa3*E3)/1000; 
end

 
        
        


    